# frozen_string_literal: true

module TurboModal
  class FormActionsComponent < ViewComponent::Base
    def initialize(form:, cancel_text: nil, submit_text: nil)
      @form        = form
      @cancel_text = cancel_text
      @submit_text = submit_text
    end

    def cancel_link_text
      @cancel_text || helpers.t("helpers.cancel")
    end
  end
end
