# frozen_string_literal: true

class Views::Pages::Landing < Views::Base
  def view_template
    div(class: "min-h-screen flex flex-col items-center justify-center gap-8 bg-base-200") do
      render Components::ProductCard.new(
        src: "https://img.daisyui.com/images/stock/photo-1606107557195-0e29a4b5b4aa.webp"
      )

      div(class: "card bg-base-100 shadow-md") do
        div(class: "card-body items-center") do
          h2(class: "card-title") { "Reactive counter" }
          render Components::Counter.new
        end
      end
    end
  end
end
