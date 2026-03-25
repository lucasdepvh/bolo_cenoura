class Category < ApplicationRecord
    has_many :products, dependent: :restrict_with_error

    def self.ransackable_attributes(auth_object = nil)
        ["description"]
    end
end
