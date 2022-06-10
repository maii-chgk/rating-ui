import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "roster", "toggle" ];
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
      element.textContent = "Показать"
    });

    const toggleButton = document.getElementById("toggle_all_rosters")
    toggleButton.textContent = "Показать все составы"
  }

  showAll() {
    this.rosterTargets.forEach((element, _) => {
      element.classList.remove("hidden");
    });

    this.toggleTargets.forEach((element, _) => {
      element.textContent = "Скрыть"
    });

    const toggleButton = document.getElementById("toggle_all_rosters")
    toggleButton.textContent = "Скрыть все составы"
  }
}
