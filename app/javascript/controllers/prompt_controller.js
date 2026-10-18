import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    function handleSucess(mess) {
      $("#toastsContainerTopRight").removeClass("d-none");
      $(".toast").toast({ delay: 2000 });
      $(".toast").toast("show");
      $(".toast").addClass("bg-success");
      $(".toast").addClass("top-0 end-0");
      $(".toast-body").html(mess);
    }

    function handleError(mess) {
      $("#toastsContainerTopRight").removeClass("d-none");
      $(".toast").toast({ delay: 2000 });
      $(".toast").toast("show");
      $(".toast").addClass("bg-danger");
      $(".toast").addClass("top-0 end-0");
      $(".toast-body").html(mess);
    }

    $(function () {
      let uidPrompt = "",
        project_id = "";
      //remove Prompt
      $(document).on("click", ".delete-prompt", function (e) {
        uidPrompt = $(this).data("id");
        project_id = $(this).data("project-id");
        e.stopPropagation();
        return false;
      });

      $(document).on("click", ".confirm-delete-prompt", function (e) {
        $.ajax({
          url: `/projects/${project_id}/prompts/${uidPrompt}`,
          type: "DELETE",
          data_type: "json",
          beforeSend: (xhr) => {
            const csrfToken = document.querySelector(
              "meta[name='csrf-token']"
            ).content;
            xhr.setRequestHeader("X-CSRF-Token", csrfToken);
          },
        })
          .done(function (data) {
            $("#modalprompt").modal("hide");
            console.log("data :>> ", data);
            // handleSucess(data ? data?.message : "Deleted successfully");
            // setTimeout(() => {
            //   window.location.reload();
            // }, 2000);
          })
          .fail(function (e) {
            handleError(e.responseJSON.error);
            $("#modalprompt").modal("hide");
            setTimeout(() => {
              window.location.reload();
            }, 2000);
          });
      });
    });
  }
}
