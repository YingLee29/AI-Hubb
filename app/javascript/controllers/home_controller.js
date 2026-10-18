import { Controller } from "@hotwired/stimulus";
// Connects to data-controller="home"
export default class extends Controller {
  connect() {
    var envDomain = $("#endpoint_url").data("domain");
    function handleSuccess(mess) {
      $("#toastsContainerTopRight").removeClass("d-none");
      $(".toast").toast({ delay: 2000 });
      $(".toast").toast("show");
      $(".toast").addClass("bg-success");
      $(".toast").addClass("top-0 end-0");
      $(".toast-body").html(mess);
    }

    // copy endpoint URl
    $(".copy-url__endpoint.btn-link").attr("title", "copy endpoint URL");
    $(document).on("click", ".copy-url__endpoint.btn-link", function (e) {
      const dataCopy = $("#endpoint_url").val();
      var tempElement = document.createElement("input");
      tempElement.value = dataCopy;
      document.body.appendChild(tempElement);
      tempElement.select();
      tempElement.setSelectionRange(0, 99999);
      document.execCommand("copy");
      document.body.removeChild(tempElement);
      handleSuccess("Copy endPoint URL successfully!");
    });

    // fill input
    var $inputName = $("#endpoint_name");
    var $inputApi = $("#endpoint_url");
    var inputApi = "";
    var selectedName = $("#prompt-form").data("prompt") || ":prompt_id";
    var $inputName = $("#endpoint_name");
    $inputName.on("input", function ($e) {
      inputApi = $e.target.value;
      const currentValue = `${envDomain}/api/v1/prompts/${selectedName}/${$e.target.value}`;
      setTimeout(() => {
        $("#endpoint_url").val(currentValue);
        $(".copy-url__endpoint").addClass("btn-link");
        $(".copy-url__endpoint").attr("title", "copy endpoint URL");
      }, 500);
    });

    $(document).on("change", ".select-role", function () {
      if ($(this).val() == "function") {
        $(this)
          .closest(".message-field")
          .find(".function-role")
          .removeClass("d-none");
      } else {
        $(this)
          .closest(".message-field")
          .find(".function-role")
          .addClass("d-none");
      }
    });

    $(document).on("click", ".delete-message", function () {
      let parrentEl = $(this).closest(".align-items-start");
      $(this).closest(".message-field").remove();
      if (parrentEl.find(".message-field").length > 1) {
        parrentEl.find(".delete-message").removeClass("d-none");
      } else {
        parrentEl.find(".delete-message").addClass("d-none");
      }
    });

    $(document).on("click", ".delete-function", function () {
      $(this).closest(".message-field").remove();
    });

    $(document).on("click", ".add-one", function () {
      $(".params-list")
        .first()
        .clone()
        .find("input:text")
        .val("")
        .end()
        .appendTo(".dynamic-stuff-dom")
        .show();
      if ($(".params-list").length > 1) {
        $(".delete-input").removeClass("d-none");
      } else {
        $(".delete-input").addClass("d-none");
      }
      attach_delete();
    });

    attach_delete();
    function attach_delete() {
      $(".delete-input").off();
      $(".delete-input").click(function () {
        $(this).closest(".form-group").remove();
        if ($(".params-list").length > 1) {
          $(".delete-input").removeClass("d-none");
        } else {
          $(".delete-input").addClass("d-none");
        }
      });
    }
  }
}
