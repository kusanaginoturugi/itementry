import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  open(event) {
    const interactive = event.target.closest("a, button, form, input, select, textarea, label")
    if (interactive) return

    const row = event.currentTarget
    const url = row.dataset.url
    if (!url) return

    Turbo.visit(url)
  }

  openByKeyboard(event) {
    if (event.key !== "Enter") return
    event.preventDefault()
    this.open(event)
  }
}
