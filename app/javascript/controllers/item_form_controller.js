import { Controller } from "@hotwired/stimulus"

// 商品コードの先頭数字で商品種類を推定し、コード欄にフォーカスを当てる
export default class extends Controller {
  static targets = ["code", "type"]

  connect() {
    this.focusCodeField()
  }

  syncType() {
    if (!this.hasCodeTarget || !this.hasTypeTarget) return
    const code = this.codeTarget.value?.trim() || ""
    const first = code.charAt(0)
    if (first.match(/^\d$/)) {
      this.typeTarget.value = first
    }
  }

  focusCodeField() {
    if (this.hasCodeTarget) {
      this.codeTarget.focus()
    }
  }
}
