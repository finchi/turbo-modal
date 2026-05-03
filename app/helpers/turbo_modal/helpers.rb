# frozen_string_literal: true

module TurboModal
  module Helpers
    def turbo_modal(**, &)
      render(TurboModal::Component.new(**), &)
    end

    def turbo_modal_tag
      turbo_frame_tag :turbo_modal, data: { turbo_permanent: true }
    end
  end
end
