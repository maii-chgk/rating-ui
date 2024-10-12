import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "table" ];
  static values = { teamTrueDLs: Object }

  connect() {
    console.log("Connected to truedl_details_controller");
    // this.addColumn();
  }

  addColumn() {
    console.log("Adding column to table");
    const table = this.tableTarget;
    const data = this.teamTrueDLsValue;
    console.log(data);

    const headerRow = table.querySelector("thead tr");
    const newHeader = document.createElement("th");
    newHeader.textContent = "New Column";
    headerRow.appendChild(newHeader);

    const bodyRows = table.querySelectorAll("tbody tr");
    bodyRows.forEach((row, index) => {
      const newCell = document.createElement("td");
      newCell.textContent = data[index] || "";
      row.appendChild(newCell);
    });
  }
}