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
    "suggestions",
    "valueField",
    "itemCodeHidden",
    "itemTypeFilter",
    "itemCard"
  ]

  connect() {
    this.previousLineCount = null
    this.previousTotalValue = null
    this.items = this.loadItemsFromDataset()
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
    const triggerDetail = event.target.closest("[data-receipt-form-target='detail']")
    const fragment = document.createDocumentFragment()
    fragment.appendChild(content)

    if (triggerDetail && triggerDetail.parentNode === this.detailsTarget) {
      triggerDetail.after(fragment)
    } else {
      this.detailsTarget.appendChild(fragment)
    }

    // focus the newly added item's code field
    const codeFields = this.detailsTarget.querySelectorAll("[data-receipt-form-target='itemCodeField']")
    const newCodeField = triggerDetail
      ? triggerDetail.nextElementSibling?.querySelector("[data-receipt-form-target='itemCodeField']")
      : codeFields[codeFields.length - 1]
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

    this.flashOnChange(this.lineCountTarget, this.previousLineCount, lineCount)
    this.flashOnChange(this.totalValueTarget, this.previousTotalValue, totalValue)
    this.previousLineCount = lineCount
    this.previousTotalValue = totalValue
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

  handleCodeInput(event) {
    const input = event.target
    const code = input.value || ""
    const detail = input.closest("[data-receipt-form-target='detail']")
    this.renderSuggestions(detail, code)
    this.recalculate()
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

  openNewItem(event) {
    event.preventDefault()
    const detail = event.target.closest("[data-receipt-form-target='detail']")
    const codeField = detail?.querySelector("[data-receipt-form-target='itemCodeField']")
    const code = codeField?.value?.trim()
    const url = new URL("/items/new", window.location.origin)
    if (code) url.searchParams.set("item[item_code]", code)
    window.location.assign(url.toString())
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

  flashOnChange(target, previousValue, newValue) {
    if (!target) return
    if (previousValue === null || previousValue === undefined) return
    if (previousValue === newValue) return
    target.classList.remove("flash-highlight")
    // force reflow to restart animation
    // eslint-disable-next-line no-unused-expressions
    target.offsetWidth
    target.classList.add("flash-highlight")
  }

  renderSuggestions(detail, code) {
    const list = detail?.querySelector("[data-receipt-form-target='suggestions']")
    if (!list || !this.items) return
    list.innerHTML = ""
    const prefix = code?.trim() || ""
    if (prefix === "") return
    const matched = this.items.filter((item) => item.code.startsWith(prefix)).slice(0, 10)
    matched.forEach((item) => {
      const row = document.createElement("div")
      row.className = "suggestion-row d-flex justify-content-between align-items-center py-1 px-2"
      row.innerHTML = `
        <span class="text-monospace fw-bold">${item.code}</span>
        <span class="flex-grow-1 mx-2 text-truncate">${item.name}</span>
        <span class="text-muted small">${Number(item.value).toLocaleString()} 円</span>
      `
      list.appendChild(row)
    })
  }

  loadItemsFromDataset() {
    const el = document.getElementById("receipt-items-data")
    if (!el) return []
    try {
      return JSON.parse(el.dataset.items || "[]")
    } catch (e) {
      return []
    }
  }
}
