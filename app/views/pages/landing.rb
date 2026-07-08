# frozen_string_literal: true

class Views::Pages::Landing < Views::Base
  def initialize(products:)
    @products = products
  end

  def view_template
    div(class: "min-h-screen flex flex-col items-center justify-center gap-8 bg-base-200 py-12") do
      div(class: "flex flex-wrap justify-center gap-8 max-w-6xl") do
        @products.each do |product|
          render Components::ProductCard.new(product: product)
        end
      end

      div(class: "card bg-base-100 shadow-md") do
        div(class: "card-body items-center") do
          h2(class: "card-title") { "Reactive counter" }
          render Components::Counter.new
        end
      end
    end
  end
end
