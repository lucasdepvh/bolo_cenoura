class AddIdentificationCodeToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :identification_code, :string
  end
end
