import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    $(function () {
      let userID;
      function handleSuccess(mess) {
        $("#toastsContainerTopRight").removeClass("d-none");
        $(".toast").toast({ delay: 2000 });
        $(".toast").toast("show");
        $(".toast").addClass("bg-success");
        $(".toast-body").html(mess);
      }

      function handleError(mess) {
        $("#toastsContainerTopRight").removeClass("d-none");
        $(".toast").toast({ delay: 2000 });
        $(".toast").toast("show");
        $(".toast").addClass("bg-danger");
        $(".toast-body").html(mess);
      }

      $(document).on("click", ".delete-user", function (e) {
        userID = $(this).data("id");
        e.stopPropagation();
        return false;
      });

      $(document).on("click", ".confirm-delete-user", function (e) {
        var eleBtn = $(".edit-user-btn");
        eleBtn.each((index, element) => {
          $(element).addClass("disable-item__action");
        });
        $.ajax({
          url: `users/${userID}`,
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
            handleSuccess(data?.message);
            setTimeout(() => {
              $("#modalUser").modal("hide");
              window.location.reload();
              eleBtn.each((index, element) => {
                $(element).removeClass("disable-item__action");
              });
            }, 2000);
          })
          .fail(function (e) {
            handleError(e.responseJSON?.error || e.statusText);
            setTimeout(() => {
              $("#modalUser").modal("hide");
              window.location.reload();
            }, 2000);
          });
      });

      $(document).on("click", ".edit-user-btn", (event) => {
        event.preventDefault();
        userID = $(event.currentTarget).data("id");
        $.ajax({
          url: `users/${userID}/render_edit`,
          type: "GET",
          data_type: "script",
          beforeSend: (xhr) => {
            const csrfToken = document.querySelector(
              "meta[name='csrf-token']"
            ).content;
            xhr.setRequestHeader("X-CSRF-Token", csrfToken);
          },
        }).fail(function (e) {
          handleError(e.responseJSON?.error || e.statusText);
          setTimeout(() => {
            window.location.reload();
          }, 2000);
        });
      });

      $(document).on("submit", ".user-form", function (e) {
        e.preventDefault();
        $(".edit-user").addClass("disable-item");
        var formData = new FormData(this);
        try {
          $.ajax({
            url: `users/${userID}`,
            cache: false,
            data: formData,
            beforeSend: (xhr) => {
              const csrfToken = document.querySelector(
                "meta[name='csrf-token']"
              ).content;
              xhr.setRequestHeader("X-CSRF-Token", csrfToken);
            },
            type: "PATCH",
            dataType: "json",
            processData: false,
            contentType: false,
          }).done(function (response) {
            const { errors } = response;
            if (response?.errors.length == 0) {
              handleSuccess(response?.message);
              setTimeout(() => {
                $("#modalUser").modal("hide");
                window.location.reload();
              }, 2000);
            } else {
              $(".edit-user").removeClass("disable-item");

              if (errors.email) {
                $(".error-email-content").text("");
                $(".error-email-validate").addClass("d-block");
                $(".error-email-content").append(errors.email[0]);
              } else {
                $(".error-email-validate").removeClass("d-block");
              }
              if (errors.name) {
                $(".error-name-content").text("");
                $(".error-name-validate").addClass("d-block");
                $(".error-name-content").append(errors.name[0]);
              } else {
                $(".error-name-validate").removeClass("d-block");
              }
              if (errors.phone) {
                $(".error-phone-content").text("");
                $(".error-phone-validate").addClass("d-block");
                $(".error-phone-content").append(errors.phone[0]);
              } else {
                $(".error-phone-validate").removeClass("d-block");
              }
            }
            })
            .fail(function (error) {
              handleError(error?.responseJSON?.error);
              setTimeout(() => {
                window.location.reload();
              }, 2000);
            });
        } catch (error) {
          console.log("error", error);
        }
      });
    });
  }
}
