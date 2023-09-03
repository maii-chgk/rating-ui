import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "ratings" ];
  static values = { hidden: Boolean }

  initialize() {
    this.hiddenValue = true;
  }

  toggle(event) {
    event.preventDefault();
    this.ratingsTarget.classList.toggle("hidden", !this.hiddenValue);

    this.hiddenValue = !this.hiddenValue;
  }
}
