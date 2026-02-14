import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "template"]

  add(event) {
    event.preventDefault()

    const uniqueId = `${Date.now()}_${Math.floor(Math.random() * 10000)}`
    const html = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, uniqueId)

    this.containerTarget.insertAdjacentHTML("beforeend", html)
  }

  remove(event) {
    event.preventDefault()

    const row = event.target.closest("[data-contact-row]")
    if (!row) return

    const destroyField = row.querySelector("input[name*='[_destroy]']")

    if (destroyField) {
      destroyField.value = "1"
      row.classList.add("d-none")
    } else {
      row.remove()
    }
  }
}
