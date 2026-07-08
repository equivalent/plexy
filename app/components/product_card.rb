# frozen_string_literal: true

class Components::ProductCard < Components::Base
  def initialize(src:)
    @src = src
  end

  def view_template
    Card :base_100, class: "w-96 shadow-sm" do |card|
      figure do
        img(src: @src, alt: "Shoes")
      end
      card.body do
        card.title do
          "Shoes!"
        end
        p do
          "If a dog chews shoes whose shoes does he choose?"
        end
        card.actions class: "justify-end" do
          Button :primary do
            "Buy Now"
          end
        end
      end
    end
  end
end
