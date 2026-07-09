# frozen_string_literal: true

class Components::ProductCard < Components::Base
  include Phlex::Reactive::Component
  include Components::Storefront

  # Demo app has no auth yet — revisit when auth lands (see CLAUDE.md).
  skip_verify_authorized

  reactive_record :product
  action :buy_now
  action :increment
  action :decrement

  def initialize(product:)
    @product = product
  end

  def id = "product-card-#{@product.id}"

  def buy_now
    CartProduct.add(@product)
    reply_and_broadcast
  end

  def increment
    CartProduct.add(@product)
    reply_and_broadcast
  end

  def decrement
    cart_product = CartProduct.find_by(product: @product)
    return unless cart_product

    if cart_product.quantity > 1
      cart_product.update!(quantity: cart_product.quantity - 1)
    else
      cart_product.destroy!
    end
    reply_and_broadcast
  end

  def view_template
    Card :base_100, **reactive_root(class: "w-96 shadow-sm") do |card|
      figure do
        img(
          src: "https://picsum.photos/seed/product-#{@product.id}/400/225",
          alt: @product.title
        )
      end
      card.body do
        card.title { @product.title }
        p { @product.description }
        card.actions class: "justify-between items-center" do
          span(class: "text-lg font-semibold") { "$#{@product.price}" }
          if (quantity = cart_quantity).positive?
            quantity_stepper(quantity)
          else
            button(**mix(on(:buy_now), class: "btn btn-primary")) { "Buy Now" }
          end
        end
      end
    end
  end

  private

  # Actor gets the reply; every other subscribed tab gets the same card +
  # cart summary via the storefront stream.
  def reply_and_broadcast
    broadcast_replace_to_peers(
      Components::ProductCard.new(product: @product),
      Components::CartSummary.new
    )
    reply.replace.also(Components::CartSummary.new)
  end

  def quantity_stepper(quantity)
    div(class: "flex items-center gap-3") do
      button(**mix(on(:decrement), class: "btn btn-sm")) { "−" }
      span(class: "text-2xl tabular-nums w-10 text-center") { quantity.to_s }
      button(**mix(on(:increment), class: "btn btn-sm")) { "+" }
    end
  end

  def cart_quantity
    CartProduct.find_by(product: @product)&.quantity.to_i
  end
end
