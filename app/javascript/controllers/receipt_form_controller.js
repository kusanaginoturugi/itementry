import { Controller } from "@hotwired/stimulus"

const ITEM_TYPE_FILTER_STORAGE_KEY = "receipt_form_item_type_filter"

export default class extends Controller {
  static targets = [
    "details",
    "template",
    "totalCount",
    "totalValue",
    "lineCount",
    "destroyField",
    "itemName",
    "itemNameField",
    "sumDisplay",
    "sumField",
    "itemIdField",
    "itemCodeField",
    "valueField",
    "itemCodeHidden",
    "itemTypeFilter",
    "itemCard"
  ]

  connect() {
    this.applyInitialValueLocks()
    this.restoreItemTypeFilter()
    this.recalculate()
    this.focusFirstCodeField()
    this.filterItemsByType()
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
      this.removeRequiredAttributes(card)
      card.classList.add("d-none")
    } else {
      card.remove()
    }

    this.recalculate()
  }

  recalculate() {
    let totalCount = 0
    let totalValue = 0
    let lineCount = 0

    this.detailsTarget.querySelectorAll("[data-receipt-form-target='detail']").forEach((detail) => {
      if (detail.classList.contains("d-none")) return
      const codeField = detail.querySelector("[data-receipt-form-target='itemCodeField']")
      const codeHidden = detail.querySelector("[data-receipt-form-target='itemCodeHidden']")
      const countInput = detail.querySelector("input[name*='[count]']")
      const valueInput = detail.querySelector("input[name*='[value]']")
      const sumInput = detail.querySelector("input[name*='[sum_value]']")
      const sumDisplay = detail.querySelector("[data-receipt-form-target='sumDisplay']")
      const count = parseInt(countInput?.value || "0", 10) || 0
      const value = parseInt(valueInput?.value || "0", 10) || 0
      const sum = count * value

      if ((codeField?.value?.trim() || codeHidden?.value?.trim())) {
        lineCount += 1
      }

      if (sumInput) sumInput.value = sum
      if (sumDisplay) sumDisplay.textContent = sum.toLocaleString()

      totalCount += count
      totalValue += sum
    })

    if (this.hasTotalCountTarget) this.totalCountTarget.textContent = totalCount
    if (this.hasTotalValueTarget) this.totalValueTarget.textContent = totalValue.toLocaleString()
    if (this.hasLineCountTarget) this.lineCountTarget.textContent = lineCount
  }

  filterItemsByType() {
    if (!this.hasItemTypeFilterTarget || !this.hasItemCardTarget) return
    const selectedType = this.itemTypeFilterTarget.value
    this.itemCardTargets.forEach((card) => {
      const type = card.dataset.itemType ?? ""
      const visible = selectedType === "" || selectedType === type
      card.classList.toggle("d-none", !visible)
    })
    this.persistItemTypeFilter(selectedType)
  }

  restoreItemTypeFilter() {
    if (!this.hasItemTypeFilterTarget) return
    try {
      const stored = window.localStorage.getItem(ITEM_TYPE_FILTER_STORAGE_KEY)
      if (stored !== null) this.itemTypeFilterTarget.value = stored
    } catch (e) {
      // ignore if localStorage is unavailable
    }
  }

  persistItemTypeFilter(value) {
    try {
      window.localStorage.setItem(ITEM_TYPE_FILTER_STORAGE_KEY, value)
    } catch (e) {
      // ignore if localStorage is unavailable
    }
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
    const codeHidden = detail.querySelector("[data-receipt-form-target='itemCodeHidden']")

    const resetFields = () => {
      if (nameField) nameField.value = ""
      if (nameDisplay) nameDisplay.textContent = "-"
      if (idField) idField.value = ""
      if (valueField) {
        valueField.value = ""
        this.toggleValueField(valueField, true)
      }
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
      if (valueField && data.value !== undefined && data.value !== null) valueField.value = data.value
      this.toggleValueField(valueField, data.is_variable_value)
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

  applyInitialValueLocks() {
    this.valueFieldTargets.forEach((field) => {
      const variable = field.dataset.variableValue
      this.toggleValueField(field, variable)
    })
  }

  toggleValueField(field, isVariable) {
    if (!field) return
    const variable = isVariable === undefined ? true : (isVariable === true || isVariable === "true")
    field.readOnly = !variable
    field.tabIndex = variable ? 0 : -1
    if (variable) {
      field.removeAttribute("tabindex")
    }
    field.classList.toggle("bg-light", !variable)
  }

  removeRequiredAttributes(scope) {
    scope.querySelectorAll("[required]").forEach((el) => {
      el.removeAttribute("required")
    })
  }
}
