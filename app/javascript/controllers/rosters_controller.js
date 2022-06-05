import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "roster" ];
  static values = { hidden: Boolean }

  initialize() {
    this.showingRosters = true;
  }

  hideall() {
    this.rosterTargets.forEach((element, _) => {
      element.classList.toggle("hidden");
    });

    this.hiddenValue = !this.hiddenValue;

    const toggleButton = document.getElementById("toggle_all_rosters")
    if (this.hiddenValue) {
      toggleButton.textContent = "Скрыть все составы"
    } else {
      toggleButton.textContent = "Показать все составы"
    }
  }
}
