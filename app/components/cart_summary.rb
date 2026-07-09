# frozen_string_literal: true

# Cart totals shown at the top of the page. ProductCard actions re-render it
# via `reply.replace.also(Components::CartSummary.new)`; its own clear_cart
# action empties the cart and re-renders the affected product cards back.
class Components::CartSummary < Components::Base
  include Phlex::Reactive::Component
  include Components::Storefront

  # Demo app has no auth yet — revisit when auth lands (see CLAUDE.md).
  skip_verify_authorized

  action :clear_cart

  def id = "cart-summary"

  def clear_cart
    products = Current.cart.map(&:product)
    CartProduct.destroy_all
    broadcast_replace_to_peers(
      Components::CartSummary.new,
      *products.map { |product| Components::ProductCard.new(product:) }
    )
    products.reduce(reply.replace) do |response, product|
      response.also(Components::ProductCard.new(product:))
    end
  end

  def view_template
    Stat(**reactive_root(class: "shadow-sm bg-base-100")) do |stat|
      stat.item(class: "place-items-center") do
        stat.value { LucideIcon(:shopping_cart, class: "size-[1em]") }
      end
      stat.item do
        stat.title { "Items in cart" }
        stat.value { total_items.to_s }
      end
      stat.item do
        stat.title { "Total price" }
        stat.value { "$#{total_price}" }
      end
      stat.item(class: "place-items-center") do
        stat.actions do
          button(**mix(on(:clear_cart), class: "btn btn-sm btn-ghost")) do
            LucideIcon(:trash_2, class: "size-4")
            plain "Clear"
          end
        end
      end
    end
  end

  private

  def total_items = Current.cart.sum(:quantity)

  def total_price = Current.cart.sum(&:total_price)
end
