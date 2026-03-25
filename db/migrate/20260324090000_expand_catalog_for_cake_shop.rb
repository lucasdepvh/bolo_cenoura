class ExpandCatalogForCakeShop < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :stock_quantity, :integer, default: 0, null: false
    add_column :products, :featured, :boolean, default: false, null: false
    add_column :products, :active, :boolean, default: true, null: false
    add_column :products, :prep_time_minutes, :integer, default: 60, null: false

    create_table :customers do |t|
      t.string :name, null: false
      t.string :email
      t.string :phone, null: false
      t.string :neighborhood
      t.string :address
      t.text :notes
      t.integer :total_orders, default: 0, null: false
      t.decimal :total_spent, precision: 10, scale: 2, default: 0, null: false
      t.datetime :last_order_at
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    create_table :orders do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :code, null: false
      t.integer :status, default: 0, null: false
      t.integer :fulfillment_type, default: 0, null: false
      t.integer :payment_method, default: 0, null: false
      t.datetime :scheduled_for
      t.datetime :delivered_at
      t.decimal :subtotal, precision: 10, scale: 2, default: 0, null: false
      t.decimal :delivery_fee, precision: 10, scale: 2, default: 0, null: false
      t.decimal :discount, precision: 10, scale: 2, default: 0, null: false
      t.decimal :total_amount, precision: 10, scale: 2, default: 0, null: false
      t.text :notes

      t.timestamps
    end

    add_index :orders, :code, unique: true

    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, foreign_key: true
      t.string :product_name, null: false
      t.integer :quantity, default: 1, null: false
      t.decimal :unit_price, precision: 10, scale: 2, default: 0, null: false
      t.decimal :total_price, precision: 10, scale: 2, default: 0, null: false

      t.timestamps
    end

    create_table :financial_entries do |t|
      t.string :title, null: false
      t.integer :kind, default: 0, null: false
      t.string :category, null: false
      t.decimal :amount, precision: 10, scale: 2, default: 0, null: false
      t.date :occurred_on, null: false
      t.integer :payment_status, default: 0, null: false
      t.text :notes
      t.references :order, foreign_key: true

      t.timestamps
    end
  end
end
