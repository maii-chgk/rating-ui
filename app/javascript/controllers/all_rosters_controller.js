import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "roster", "toggle", "globalToggle" ];
  static values = { rostersHidden: Boolean }

  initialize() {
    this.rostersHiddenValue = true;
  }

  toggleAll() {
    if (this.rostersHiddenValue) {
      this.showAll()
    } else {
      this.hideAll()
    }

    this.rostersHiddenValue = !this.rostersHiddenValue
  }

  hideAll() {
    this.rosterTargets.forEach((element, _) => {
      element.classList.add("hidden");
    });

    this.toggleTargets.forEach((element, _) => {
      element.classList.remove("hidden");
    });

    this.globalToggleTarget.textContent = "Показать все составы"
  }

  showAll() {
    this.rosterTargets.forEach((element, _) => {
      element.classList.remove("hidden");
    });

    this.toggleTargets.forEach((element, _) => {
      element.classList.add("hidden");
    });

    this.globalToggleTarget.textContent = "Скрыть все составы"
  }
}
