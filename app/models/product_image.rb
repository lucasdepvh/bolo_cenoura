class ProductImage < ApplicationRecord
  belongs_to :product

  before_save do
    self.filetype = self.data.content_type
    self.data = self.data.read
  end
end
