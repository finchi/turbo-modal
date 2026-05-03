import { Turbo } from "@hotwired/turbo-rails"

Turbo.StreamActions.redirect = function() {
  const target = this.getAttribute("target")
  const options = target === location.href || target === location.pathname
    ? { action: "replace" }
    : {}
  Turbo.visit(target, options)
}

export { TurboModalController } from "./turbo_modal_controller.js"
