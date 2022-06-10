import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "roster", "toggle" ];
  static values = { rosterHidden: Boolean }

  initialize() {
    this.rosterHiddenValue = true;
  }

  toggle(event) {
    event.preventDefault()

    if (this.rosterHiddenValue) {
      this.show()
    } else {
      this.hide()
    }

    this.rosterHiddenValue = !this.rosterHiddenValue
  }

  hide() {
    this.rosterTarget.classList.add("hidden")
    this.toggleTarget.textContent = "Показать"
  }

  show() {
    this.rosterTarget.classList.remove("hidden")
    this.toggleTarget.textContent = "Скрыть"
  }
}
