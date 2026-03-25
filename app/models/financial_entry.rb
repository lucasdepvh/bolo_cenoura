class FinancialEntry < ApplicationRecord
  belongs_to :order, optional: true

  enum kind: {
    income: 0,
    expense: 1
  }

  enum payment_status: {
    pending: 0,
    paid: 1,
    overdue: 2
  }

  validates :title, :category, :amount, :occurred_on, presence: true

  scope :recent_first, -> { order(occurred_on: :desc, created_at: :desc) }

  def self.ransackable_attributes(_auth_object = nil)
    %w[amount category created_at kind occurred_on payment_status title]
  end

  def kind_label
    income? ? "Receita" : "Despesa"
  end

  def kind_badge_class
    income? ? "success" : "danger"
  end

  def payment_status_label
    {
      "pending" => "Pendente",
      "paid" => "Pago",
      "overdue" => "Atrasado"
    }[payment_status]
  end

  def self.ransackable_associations(_auth_object = nil)
    ["order"]
  end

  def editable_manually?
    order_id.blank?
  end
end
