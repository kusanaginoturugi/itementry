import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "filter", "card" ]

  connect() {
    this.filter()
  }

  filter() {
    if (!this.hasFilterTarget || !this.hasCardTarget) return
    const selected = this.filterTarget.value
    this.cardTargets.forEach((card) => {
      const type = card.dataset.itemType ?? ""
      const visible = selected === "" || selected === type
      card.classList.toggle("d-none", !visible)
    })
  }
}
