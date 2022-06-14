import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "roster", "show" ];

  hide() {
    this.rosterTarget.classList.add("hidden")
    this.showTarget.classList.remove("hidden")
  }

  show(event) {
    event.preventDefault()
    this.rosterTarget.classList.remove("hidden")
    this.showTarget.classList.add("hidden")
  }
}
