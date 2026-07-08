require "test_helper"

class CurrentCartTest < ActiveSupport::TestCase
  setup do
    CartProduct.delete_all
    @drumsticks = products(:one)
    @cymbal = products(:two)
  end

  test "cart is empty when nothing has been added" do
    assert_empty Current.cart
  end

  test "cart returns CartProduct instances for added products" do
    CartProduct.add(@drumsticks, quantity: 3)
    CartProduct.add(@cymbal, quantity: 4)

    cart = Current.cart.to_a
    assert_equal 2, cart.size
    assert cart.all? { |item| item.is_a?(CartProduct) }

    assert_equal [ [ @drumsticks.id, 3 ], [ @cymbal.id, 4 ] ],
      cart.map { |item| [ item.product_id, item.quantity ] }
  end

  test "adding the same product again bumps its quantity instead of creating a new row" do
    CartProduct.add(@drumsticks, quantity: 3)
    CartProduct.add(@drumsticks, quantity: 2)

    assert_equal 1, Current.cart.count
    assert_equal 5, Current.cart.first.quantity
  end

  test "adding defaults to quantity 1" do
    CartProduct.add(@drumsticks)

    assert_equal 1, Current.cart.first.quantity
  end

  test "cart items know their total price" do
    CartProduct.add(@drumsticks, quantity: 3)

    assert_equal @drumsticks.price * 3, Current.cart.first.total_price
  end

  test "cart survives a Current reset because it is backed by the database" do
    CartProduct.add(@drumsticks, quantity: 2)
    Current.reset

    assert_equal 1, Current.cart.count
    assert_equal 2, Current.cart.first.quantity
  end

  test "a product cannot be in the cart twice" do
    CartProduct.create!(product: @drumsticks, quantity: 1)

    assert_raises(ActiveRecord::RecordInvalid) do
      CartProduct.create!(product: @drumsticks, quantity: 1)
    end
  end

  test "quantity must be a positive integer" do
    assert_not CartProduct.new(product: @drumsticks, quantity: 0).valid?
    assert_not CartProduct.new(product: @drumsticks, quantity: -1).valid?
    assert CartProduct.new(product: @drumsticks, quantity: 1).valid?
  end
end
