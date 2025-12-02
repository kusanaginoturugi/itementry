import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "details",
    "template",
    "totalCount",
    "totalValue",
    "itemKinds",
    "destroyField",
    "itemName",
    "itemNameField",
    "sumDisplay",
    "sumField",
    "itemIdField",
    "itemCodeField",
    "valueField",
    "valueDisplay",
    "itemCodeHidden"
  ]

  connect() {
    this.recalculate()
    this.focusFirstCodeField()
  }

  addDetail(event) {
    event.preventDefault()
    const content = this.templateTarget.content.cloneNode(true)
    const newId = new Date().getTime()
    content.querySelectorAll("[name]").forEach((el) => {
      el.name = el.name.replace("NEW_RECORD", newId)
      if (el.id) el.id = el.id.replace("NEW_RECORD", newId)
    })
    this.detailsTarget.appendChild(content)

    // focus the newly added item's code field
    const codeFields = this.detailsTarget.querySelectorAll("[data-receipt-form-target='itemCodeField']")
    const newCodeField = codeFields[codeFields.length - 1]
    if (newCodeField) newCodeField.focus()

    this.recalculate()
  }

  removeDetail(event) {
    event.preventDefault()
    const card = event.target.closest("[data-receipt-form-target='detail']")
    if (!card) return
    const destroyField = card.querySelector("[data-receipt-form-target='destroyField']")

    if (destroyField) {
      destroyField.value = "1"
      card.classList.add("d-none")
    } else {
      card.remove()
    }

    this.recalculate()
  }

  recalculate() {
    let totalCount = 0
    let totalValue = 0
    let kindsCount = 0

    this.detailsTarget.querySelectorAll("[data-receipt-form-target='detail']").forEach((detail) => {
      if (detail.classList.contains("d-none")) return
      const codeField = detail.querySelector("[data-receipt-form-target='itemCodeField']")
      const codeHidden = detail.querySelector("[data-receipt-form-target='itemCodeHidden']")
      const countInput = detail.querySelector("input[name*='[count]']")
      const valueInput = detail.querySelector("input[name*='[value]']")
      const valueDisplay = detail.querySelector("[data-receipt-form-target='valueDisplay']")
      const sumInput = detail.querySelector("input[name*='[sum_value]']")
      const sumDisplay = detail.querySelector("[data-receipt-form-target='sumDisplay']")
      const count = parseInt(countInput?.value || "0", 10) || 0
      const value = parseInt(valueInput?.value || "0", 10) || 0
      const sum = count * value

      if ((codeField?.value?.trim() || codeHidden?.value?.trim())) {
        kindsCount += 1
      }

      if (sumInput) sumInput.value = sum
      if (sumDisplay) sumDisplay.textContent = sum.toLocaleString()
      if (valueDisplay) valueDisplay.textContent = value.toLocaleString()

      totalCount += count
      totalValue += sum
    })

    if (this.hasTotalCountTarget) this.totalCountTarget.textContent = totalCount
    if (this.hasTotalValueTarget) this.totalValueTarget.textContent = totalValue.toLocaleString()
    if (this.hasItemKindsTarget) this.itemKindsTarget.textContent = kindsCount
  }

  async loadItemName(event) {
    const input = event.target
    const code = input.value?.trim()
    const detail = input.closest("[data-receipt-form-target='detail']")
    if (!detail) return
    const nameField = detail.querySelector("[data-receipt-form-target='itemNameField']")
    const nameDisplay = detail.querySelector("[data-receipt-form-target='itemName']")
    const idField = detail.querySelector("[data-receipt-form-target='itemIdField']")
    const valueField = detail.querySelector("[data-receipt-form-target='valueField']")
    const valueDisplay = detail.querySelector("[data-receipt-form-target='valueDisplay']")
    const codeHidden = detail.querySelector("[data-receipt-form-target='itemCodeHidden']")

    const resetFields = () => {
      if (nameField) nameField.value = ""
      if (nameDisplay) nameDisplay.textContent = "-"
      if (idField) idField.value = ""
      if (valueField) valueField.value = ""
      if (valueDisplay) valueDisplay.textContent = "-"
      if (codeHidden) codeHidden.value = ""
    }

    if (!code) {
      resetFields()
      this.recalculate()
      return
    }

    // If fields are prefilled (edit page), avoid refetching same code
    if (codeHidden?.value === code && (nameField?.value || nameDisplay?.textContent?.trim() !== "-")) {
      this.recalculate()
      return
    }

    try {
      const response = await fetch(`/items/lookup.json?item_code=${encodeURIComponent(code)}`)
      if (!response.ok) throw new Error("Not found")
      const data = await response.json()
      if (nameField) nameField.value = data.name || ""
      if (nameDisplay) nameDisplay.textContent = data.name || "-"
      if (idField) idField.value = data.id || ""
      if (valueField && data.value) valueField.value = data.value
      if (valueDisplay) valueDisplay.textContent = data.value?.toLocaleString?.() || data.value || "-"
      if (codeHidden) codeHidden.value = data.item_code || ""
    } catch (e) {
      resetFields()
    }

    this.recalculate()
  }

  focusFirstCodeField() {
    const codeField = this.detailsTarget.querySelector("[data-receipt-form-target='itemCodeField']")
    if (codeField) codeField.focus()
  }
}
