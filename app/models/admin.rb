class Admin < ApplicationRecord
    devise :database_authenticatable, :recoverable,
           :rememberable, :validatable, :timeoutable

        def to_s
            name
        end
      
        def name=(value)
           write_attribute(:name, value.to_s.upcase)
        end
  end
