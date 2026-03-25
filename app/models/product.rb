class Product < ApplicationRecord
  belongs_to :category
  has_many :images, class_name: 'ProductImage', dependent: :destroy
  has_many :order_items, dependent: :nullify

  scope :related_to, ->(product) { where(category_id: product.category_id).where.not(id: product.id) }
  scope :active_first, -> { order(featured: :desc, active: :desc, created_at: :desc) }

  accepts_nested_attributes_for :images, allow_destroy: true

  validates :title, :price, :category, presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["active", "category_id", "created_at", "description", "featured", "id", "identification_code", "prep_time_minutes", "price", "stock_quantity", "title", "updated_at", "views_count"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["category", "images"]
  end
end
