class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product, optional: true

  validates :product_name, :quantity, :unit_price, presence: true

  before_validation :copy_product_name
  before_save :recalculate_total
  after_save :sync_order_totals
  after_destroy :sync_order_totals

  def self.ransackable_attributes(_auth_object = nil)
    %w[product_name quantity total_price unit_price]
  end

  private

  def copy_product_name
    self.product_name ||= product&.title
  end

  def recalculate_total
    self.total_price = quantity.to_i * unit_price.to_f
  end

  def sync_order_totals
    order.save!
  end
end
