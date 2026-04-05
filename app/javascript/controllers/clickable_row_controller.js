import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  go(event) {
    if (!this.hasUrlValue) return
    if (event.target.closest("a, button, form")) return

    window.location.href = this.urlValue
  }

  goWithKeyboard(event) {
    if (event.key !== "Enter" && event.key !== " ") return

    event.preventDefault()
    this.go(event)
  }
}
