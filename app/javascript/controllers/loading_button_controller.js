import { Controller } from "@hotwired/stimulus"

// Shows a spinner and disables the submit button while the browser follows the sign in redirects.
export default class extends Controller {
  static targets = ["button", "label"]
  static values = { text: { type: String, default: "Signing in..." } }

  start() {
    setTimeout(() => {
      this.buttonTarget.disabled = true
      this.buttonTarget.classList.add("loading")
      this.labelTarget.textContent = this.textValue
    }, 0)
  }
}
