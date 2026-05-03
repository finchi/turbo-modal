# frozen_string_literal: true

module TurboModal
  class Engine < ::Rails::Engine
    initializer "turbo_modal.helpers" do
      ActiveSupport.on_load(:action_view) do
        include TurboModal::Helpers
      end
    end
  end
end
