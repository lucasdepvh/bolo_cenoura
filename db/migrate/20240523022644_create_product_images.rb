class CreateProductImages < ActiveRecord::Migration[7.0]
  def change
    create_table :product_images do |t|
      t.binary :data
      t.string :filetype
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end
  end
end
