import { Controller } from "@hotwired/stimulus"

// Shows a spinner and disables the submit button while the request or redirects are in flight.
export default class extends Controller {
  static targets = ["button", "label"]
  static values = { text: { type: String, default: "Signing in..." } }

  start() {
    this.originalText = this.labelTarget.textContent
    setTimeout(() => {
      this.buttonTarget.disabled = true
      this.buttonTarget.classList.add("loading")
      this.labelTarget.textContent = this.textValue
    }, 0)
  }

  stop() {
    this.buttonTarget.disabled = false
    this.buttonTarget.classList.remove("loading")
    if (this.originalText) this.labelTarget.textContent = this.originalText
  }
}
