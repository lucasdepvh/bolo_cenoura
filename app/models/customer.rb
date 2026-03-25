class Customer < ApplicationRecord
  has_many :orders, dependent: :destroy

  validates :name, :phone, presence: true

  scope :active_first, -> { order(active: :desc, last_order_at: :desc, created_at: :desc) }

  def self.ransackable_attributes(_auth_object = nil)
    %w[active created_at email name neighborhood phone total_orders total_spent]
  end

  def self.ransackable_associations(_auth_object = nil)
    ["orders"]
  end
end
