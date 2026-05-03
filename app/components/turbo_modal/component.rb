# frozen_string_literal: true

module TurboModal
  class Component < ViewComponent::Base
    renders_one :modal_html
    renders_one :modal_header
    renders_one :modal_footer
    renders_one :modal_form_footer, TurboModal::FormActionsComponent

    def initialize(
      title: nil,
      modal_backdrop: true,
      modal_static_backdrop: false,
      modal_size: nil,
      modal_header_tag: :h3
    )
      @title                 = title
      @modal_backdrop        = modal_backdrop
      @modal_static_backdrop = modal_static_backdrop
      @modal_size            = modal_size
      @modal_header_tag      = modal_header_tag.to_sym
    end

    def inside_modal?
      helpers.turbo_frame_request_id.present?
    end

    def outside_modal?
      !inside_modal?
    end

    def turbo_form?
      inside_modal? || (helpers.respond_to?(:hotwire_native_app?) && helpers.hotwire_native_app?)
    end

    def modal_dialog_classes
      ["modal-dialog", @modal_size].compact_blank
    end
  end
end
