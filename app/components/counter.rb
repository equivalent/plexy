# frozen_string_literal: true

# The counter demo from https://phlex-reactive.zoolutions.llc/demos/counter —
# the simplest reactive shape: reactive_state + actions with and without
# params, plus a few reply.* styles.
class Components::Counter < Components::Base
  include Phlex::Reactive::Component
  include Components::Storefront

  # Public demo component with no user-scoped data — nothing to authorize.
  skip_verify_authorized

  reactive_state :count
  action :increment
  action :decrement
  action :set, params: { count: :integer }
  action :reset_with_flash
  action :bump_via_morph

  def initialize(count: 0)
    @count = count
  end

  def id = "counter"

  def increment = broadcast_count { @count += 1 }
  def decrement = broadcast_count { @count -= 1 }
  def set(count:) = broadcast_count { @count = count }

  def reset_with_flash
    broadcast_count { @count = 0 }
    reply.replace.flash(:notice, "Reset")
  end

  def bump_via_morph
    broadcast_count { @count += 1 }
    reply.morph
  end

  # Counter state lives in each tab's signed token, so peers just mirror the
  # actor's latest count (last writer wins) — enough for the cross-tab demo.
  private def broadcast_count
    yield
    broadcast_replace_to_peers(Components::Counter.new(count: @count))
  end

  def view_template
    div(**reactive_root(class: "flex items-center gap-3")) do
      button(**mix(on(:decrement), class: "btn btn-sm", data: { testid: "dec" })) { "−" }
      span(class: "text-2xl tabular-nums w-10 text-center",
           data: { testid: "count" }) { @count.to_s }
      button(**mix(on(:increment), class: "btn btn-sm", data: { testid: "inc" })) { "+" }
      button(**mix(on(:bump_via_morph), class: "btn btn-sm btn-ghost",
                                        data: { testid: "bump-morph" })) { "+1 (morph)" }
      button(**mix(on(:reset_with_flash), class: "btn btn-sm btn-ghost",
                                          data: { testid: "reset" })) { "reset" }
    end
  end
end
