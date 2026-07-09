# frozen_string_literal: true

# Cross-tab live updates. Every tab subscribes to the one storefront stream on
# the landing page (`turbo_stream_from STREAM`); a reactive action passes fresh
# component instances here so peer tabs receive the same update the actor got
# in its HTTP reply. `exclude:` suppresses the actor's own echo. Fresh
# instances are required — Phlex components render once, and `self`/the reply
# components are already spoken for.
module Components::Storefront
  STREAM = :storefront

  private

  def broadcast_replace_to_peers(*components)
    components.each do |component|
      # morph: patches the peer's DOM in place, preserving its focus/caret.
      component.class.broadcast_to(STREAM, replace: component, morph: true, exclude: reactive_connection_id)
    end
  end
end
