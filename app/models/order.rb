class Order < ApplicationRecord
  belongs_to :customer
  has_many :order_items, dependent: :destroy
  has_many :financial_entries, dependent: :destroy

  enum status: {
    pending: 0,
    confirmed: 1,
    preparing: 2,
    ready: 3,
    out_for_delivery: 4,
    delivered: 5,
    canceled: 6
  }

  enum fulfillment_type: {
    delivery: 0,
    pickup: 1
  }

  enum payment_method: {
    pix: 0,
    cash: 1,
    credit_card: 2,
    debit_card: 3
  }

  validates :code, presence: true, uniqueness: true
  validates :customer, presence: true
  validate :enough_stock_for_confirmation

  before_validation :generate_code, on: :create
  before_save :recalculate_totals
  after_save :sync_customer_summary
  after_commit :sync_stock_levels, on: [:create, :update]
  after_commit :sync_financial_entry, on: [:create, :update]
  after_destroy :sync_customer_summary
  after_destroy :restore_stock_if_needed

  scope :recent_first, -> { order(created_at: :desc) }

  def self.ransackable_attributes(_auth_object = nil)
    %w[code created_at customer_id fulfillment_type payment_method scheduled_for status total_amount]
  end

  def self.ransackable_associations(_auth_object = nil)
    ["customer", "order_items"]
  end

  def status_badge_class
    {
      "pending" => "warning",
      "confirmed" => "info",
      "preparing" => "primary",
      "ready" => "secondary",
      "out_for_delivery" => "dark",
      "delivered" => "success",
      "canceled" => "danger"
    }[status] || "secondary"
  end

  def status_label
    {
      "pending" => "Pendente",
      "confirmed" => "Confirmado",
      "preparing" => "Em preparo",
      "ready" => "Pronto",
      "out_for_delivery" => "Saiu para entrega",
      "delivered" => "Entregue",
      "canceled" => "Cancelado"
    }[status]
  end

  def fulfillment_type_label
    delivery? ? "Entrega" : "Retirada"
  end

  def payment_method_label
    {
      "pix" => "Pix",
      "cash" => "Dinheiro",
      "credit_card" => "Cartao de credito",
      "debit_card" => "Cartao de debito"
    }[payment_method]
  end

  def consuming_stock?
    confirmed? || preparing? || ready? || out_for_delivery? || delivered?
  end

  private

  def generate_code
    self.code ||= "CBC-#{Time.current.strftime('%y%m')}-#{SecureRandom.hex(2).upcase}"
  end

  def recalculate_totals
    self.subtotal = order_items.sum(&:total_price)
    self.total_amount = subtotal + delivery_fee - discount
  end

  def sync_customer_summary
    customer.update(
      total_orders: customer.orders.count,
      total_spent: customer.orders.delivered.sum(:total_amount),
      last_order_at: customer.orders.maximum(:created_at)
    )
  end

  def enough_stock_for_confirmation
    return unless consuming_stock?
    return if stock_deducted?

    order_items.each do |item|
      next unless item.product.present?
      next if item.product.stock_quantity >= item.quantity

      errors.add(:base, "Estoque insuficiente para #{item.product_name}. Disponivel: #{item.product.stock_quantity}")
    end
  end

  def sync_stock_levels
    if consuming_stock? && !stock_deducted?
      deduct_stock!
    elsif canceled? && stock_deducted?
      restore_stock!
    end
  end

  def deduct_stock!
    transaction do
      order_items.includes(:product).each do |item|
        next unless item.product.present?

        item.product.update!(stock_quantity: item.product.stock_quantity - item.quantity)
      end
      update_column(:stock_deducted, true)
    end
  end

  def restore_stock!
    transaction do
      order_items.includes(:product).each do |item|
        next unless item.product.present?

        item.product.update!(stock_quantity: item.product.stock_quantity + item.quantity)
      end
      update_column(:stock_deducted, false)
    end
  end

  def restore_stock_if_needed
    restore_stock! if stock_deducted?
  end

  def sync_financial_entry
    entry = financial_entries.find_or_initialize_by(kind: :income)
    entry.title = "Venda #{code}"
    entry.category = fulfillment_type_label
    entry.amount = total_amount
    entry.occurred_on = (delivered_at || created_at || Time.current).to_date
    entry.payment_status =
      if delivered?
        :paid
      elsif canceled?
        :overdue
      else
        :pending
      end
    entry.notes = notes
    entry.save!
  end
end
