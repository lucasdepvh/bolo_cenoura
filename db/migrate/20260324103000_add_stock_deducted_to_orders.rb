class AddStockDeductedToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :stock_deducted, :boolean, default: false, null: false
  end
end
