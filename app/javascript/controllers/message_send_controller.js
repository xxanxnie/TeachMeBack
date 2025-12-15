import { Controller } from "@hotwired/stimulus"

// Allows pressing Enter to send, Shift+Enter for newline
export default class extends Controller {
  static targets = ["form", "input"]

  submitOnEnter(event) {
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault()
      this.formTarget.requestSubmit()
    }
  }
}
