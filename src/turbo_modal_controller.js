import {Controller} from "@hotwired/stimulus"
import {Turbo} from "@hotwired/turbo-rails"
import {Modal} from "@coreui/coreui"

export class TurboModalController extends Controller {
	static values = {
		advanceUrl: String,
		backdrop: {type: Boolean, default: true},
		staticBackdrop: {type: Boolean, default: false},
	}

	connect() {
		let body = document.querySelectorAll("body")[0]
		if (body) {
			body.removeAttribute("style")
			body.classList.remove("modal-open")
		}

		this.turboFrame = this.element.closest("turbo-frame");
		this.modal      = new Modal(this.element, {
			backdrop: this.#backdrop()
		})
		this.showModal()


		// hide modal when back button is pressed
		this._onPopstate = () => {
			if (this.#hasHistoryAdvanced()) this.hideModal()
		}
		window.addEventListener('popstate', this._onPopstate)
	}

	disconnect() {
		window.removeEventListener('popstate', this._onPopstate)
		this.modal.dispose()
		document.body.classList.remove("modal-open")
		document.body.style.removeProperty("overflow")
		document.body.style.removeProperty("padding-right")
	}

	showModal() {
		this.modal.show()
		this.turboFrame.append(document.body.querySelector(".modal-backdrop"))
		if (this.advanceUrlValue && !this.#hasHistoryAdvanced()) {
			this.#setHistoryAdvanced()
			history.pushState({}, "", this.advanceUrlValue)
		}
	}

	hideModal() {
		if (this.hidingModal) return
		this.hidingModal = true

		this.modal.hide()

		if (this.#hasHistoryAdvanced()) history.back()
	}

	resetModalElement() {
		this.turboFrame.removeAttribute("src")
		this.element.remove()
		this.#resetHistoryAdvanced()
	}

	handleResponse(event) {
		const fallbackToDefaultActions = event.detail.render
		event.detail.render            = (streamElement) => {
			if (streamElement.action === "redirect") {
				this.resetModalElement()
				if (streamElement.target === location.href || streamElement.target === location.pathname)
					Turbo.visit(streamElement.target, {action: "replace"})
				else
					Turbo.visit(streamElement.target)
			} else {
				fallbackToDefaultActions(streamElement)
			}
		}
	}

	#hasHistoryAdvanced() {
		return document.body.getAttribute("data-turbo-modal-history-advanced") === "true"
	}

	#setHistoryAdvanced() {
		return document.body.setAttribute("data-turbo-modal-history-advanced", "true")
	}

	#resetHistoryAdvanced() {
		document.body.removeAttribute("data-turbo-modal-history-advanced")
	}

	#backdrop() {
		return this.staticBackdropValue ? "static" : this.backdropValue
	}
}