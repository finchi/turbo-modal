# frozen_string_literal: true

module TurboModal
  module Redirects
    extend ActiveSupport::Concern

    class_methods do
      def redirect_on_record_not_found_to(route, alert: nil)
        rescue_from ActiveRecord::RecordNotFound do
          respond_to do |format|
            format.turbo_stream { turbo_modal_redirect_to helpers.url_for(route), alert: alert }
            format.html { redirect_to helpers.url_for(route), alert: alert }
          end
        end
      end
    end

    private

    def turbo_modal_redirect_to(target, notice: nil, alert: nil, status: 302)
      flash[:notice] = notice if notice.present?
      flash[:alert]  = alert if alert.present?
      render(turbo_stream: turbo_stream.action(:redirect, helpers.url_for(target)), status: status)
    end

    def turbo_modal_redirect_back(fallback_location:, allow_other_host: _allow_other_host, notice: nil, alert: nil, status: 302)
      flash[:notice] = notice if notice.present?
      flash[:alert]  = alert if alert.present?

      native = respond_to?(:hotwire_native_app?) && hotwire_native_app?

      target = if native
        helpers.url_for(fallback_location)
      elsif request.referer && (allow_other_host || turbo_modal_host_allowed?(request.referer))
        request.referer
      else
        helpers.url_for(fallback_location)
      end

      render(turbo_stream: turbo_stream.action(:redirect, target), status: status)
    end

    # Override in the host to allow extra hosts for modal redirect-back.
    def turbo_modal_host_allowed?(url)
      _url_host_allowed?(url)
    end
  end
end
