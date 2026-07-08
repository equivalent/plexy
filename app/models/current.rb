class Current < ActiveSupport::CurrentAttributes
  # Demo app: a single global cart shared by the one-and-only session,
  # so `cart` reads straight from the table instead of a per-user scope.
  def cart
    CartProduct.includes(:product).order(:created_at)
  end
end
