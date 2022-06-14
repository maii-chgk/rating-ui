import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "release", "toggle" ];
  static values = { releasesHidden: Boolean }

  initialize() {
    this.releasesHiddenValue = true;
  }

  toggle() {
    if (this.releasesHiddenValue) {
      this.showAll()
    } else {
      this.hideAll()
    }

    this.releasesHiddenValue = !this.releasesHiddenValue
  }

  hideAll() {
    this.releaseTargets.forEach((element, _) => {
      element.classList.add("hidden");
    });

    this.toggleTarget.textContent = "Показать релизы без турниров"
  }

  showAll() {
    this.releaseTargets.forEach((element, _) => {
      element.classList.remove("hidden");
    });

    this.toggleTarget.textContent = "Скрыть релизы без турниров"
  }
}
