# frozen_string_literal: true

class Views::Pages::Landing < Views::Base
  def view_template
    div(class: "min-h-screen flex items-center justify-center bg-base-200") do
      render Components::ProductCard.new(
        src: "https://img.daisyui.com/images/stock/photo-1606107557195-0e29a4b5b4aa.webp"
      )
    end
  end
end
