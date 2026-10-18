import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["account", "security", "accountBtn", "securityBtn"];
  changeTabAccount() {
    this.accountTarget.classList.remove("d-none");
    this.securityTarget.classList.add("d-none");
    this.accountBtnTarget.classList.add("active");
    this.securityBtnTarget.classList.remove("active");
  }
  changeTabSecurity() {
    this.accountTarget.classList.add("d-none");
    this.securityTarget.classList.remove("d-none");
    this.accountBtnTarget.classList.remove("active");
    this.securityBtnTarget.classList.add("active");
  }
  connect() {
    $(function () {
      setTimeout(function () {
        $(".hidden-flash").addClass("d-none");
      }, 3000);

      const err = $("#error_explanation");
      if (err.length != 0) {
        $(".change_password").removeClass("d-none");
        $(".change_info").addClass("d-none");
        $(".account").removeClass("active");
        $(".password").addClass("active");
      } else {
        $(".change_info").removeClass("d-none");
        $(".change_password").addClass("d-none");
        $(".account").addClass("active");
      }
    });
  }
}
