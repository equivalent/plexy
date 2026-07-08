class CreateCartProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :cart_products do |t|
      t.references :product, null: false, foreign_key: true, index: { unique: true }
      t.integer :quantity, null: false, default: 1

      t.timestamps
    end
  end
end
