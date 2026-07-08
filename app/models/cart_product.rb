class CartProduct < ApplicationRecord
  belongs_to :product

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :product_id, uniqueness: true

  # Adds a product to the cart, bumping quantity if it's already there.
  def self.add(product, quantity: 1)
    cart_product = find_or_initialize_by(product: product)
    cart_product.quantity = cart_product.persisted? ? cart_product.quantity + quantity : quantity
    cart_product.save!
    cart_product
  end

  def total_price
    product.price * quantity
  end
end
