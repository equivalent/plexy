# frozen_string_literal: true

class Views::Pages::Landing < Views::Base
  include Phlex::Rails::Helpers::TurboStreamFrom

  def initialize(products:)
    @products = products
  end

  def view_template
    # Subscribe every tab to the storefront stream (pgbus patches this helper
    # to render an SSE <pgbus-stream-source>). Reactive actions broadcast their
    # updates here so peer tabs stay live — see Components::Storefront.
    turbo_stream_from :storefront

    div(class: "flex flex-col items-center justify-center gap-8 py-12") do
      Alert(:info, :soft, class: "max-w-3xl") do
        LucideIcon(:info, class: "size-5 shrink-0")
        span do
          plain "This is a vibe-coded demo project, built just to test out the capabilities of "
          a(href: "https://github.com/mhenrixon/phlex-reactive", target: "_blank", rel: "noopener", class: "link") { "phlex-reactive" }
          plain ". You can check out the source code on "
          a(href: Components::GithubLink::REPO_URL, target: "_blank", rel: "noopener", class: "link") { "GitHub" }
          plain "."
        end
      end

      render Components::CartSummary.new

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
