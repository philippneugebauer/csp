import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.reset()
  }

  resetOnSuccess(event) {
    if (event.detail.success) {
      this.reset()
    }
  }

  reset() {
    if (this.element instanceof HTMLFormElement) {
      this.element.reset()
    }
  }
}
