import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="project"
export default class extends Controller {
  connect() {
    $(document).ready(function () {
      var selectManager = new Choices(".select-user_manager", {
        removeItemButton: true,
        allowHTML: true,
      });

      var selectMember = new Choices(".select-user_member", {
        removeItemButton: true,
        allowHTML: true,
      });
      var list_users = [];
      let choices_role = [];
    });

    // create new project
    let type, idProject, name, description;
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
    function changeUrl() {
      const currentUrl = window.location.href;
      const searchParams = new URLSearchParams(currentUrl);
      if (searchParams.toString() !== "") {
        searchParams.delete("keyword");
        const newUrl = window.location.origin + window.location.pathname;
        window.location.href = newUrl;
      }
    }

    var isProcess = false;
    $(document).on("submit", ".project-form", (event) => {
      event.preventDefault();
      var name = $("#name").val().trim();
      var description = $("#description").val().trim();
      var application_domain = $("#application_domain").val().trim();
      var managerList = $("#choices-multiple-remove-button").val() || [];
      var memberList = $(".role-member-list").val() || [];
      var ipWhiteList = $("#ip_white_list").val() || "";
      const projectNameValidate = $(".project_name").data("validate-mess");
      const appDomainValidate = $(".application_domain").data("validate-mess");
      if (!name && !application_domain) {
        $(".error-name-content").text(projectNameValidate);
        $(".error-application-content").text(appDomainValidate);
        return;
      }
      if (name == "") {
        $(".error-name-content").text(projectNameValidate);
        return;
      }
      if (!application_domain) {
        $(".error-application-content").text(appDomainValidate);
        return;
      }
      if (!isProcess) {
        $(".error-name-content").text("");
        $(".error-application-content").text("");
        isProcess = true;
        if (idProject) {
          $.ajax({
            url: `/projects/${idProject}`,
            method: "PATCH",
            dataType: "script",
            data: {
              name,
              description,
              application_domain,
              users_manager: managerList,
              users_member: memberList,
              ip_white_list: ipWhiteList,
            },
            beforeSend: (xhr) => {
              const csrfToken = document.querySelector(
                "meta[name='csrf-token']"
              ).content;
              xhr.setRequestHeader("X-CSRF-Token", csrfToken);
            },
          })
            .done((res) => {
              const messageSuccess = $("#createProject").data("update-success");
              handleSucess(res ? res.message : messageSuccess);
              setTimeout(() => {
                $("#createProject").modal("hide");
                changeUrl();
                isProcess = false;
              }, 700);
            })
            .fail(function (e) {
              handleError("Updated failed!");
              setTimeout(() => {
                $("#createProject").modal("hide");
                changeUrl();
                isProcess = false;
              }, 700);
            });
        } else {
          $.ajax({
            url: "/projects",
            method: "POST",
            dataType: "script",
            data: {
              name,
              description,
              application_domain,
              users_manager: managerList,
              users_member: memberList,
              ip_white_list: ipWhiteList,
            },
            beforeSend: (xhr) => {
              const csrfToken = document.querySelector(
                "meta[name='csrf-token']"
              ).content;
              xhr.setRequestHeader("X-CSRF-Token", csrfToken);
            },
          })
            .done((res) => {
              const messageSuccess = $("#createProject").data("create-success");
              handleSucess(res ? res.message : messageSuccess);
              setTimeout(() => {
                $("#createProject").modal("hide");
                changeUrl();
                isProcess = false;
              }, 700);
            })
            .fail(function (e) {
              handleError("Created failed!");
              setTimeout(() => {
                changeUrl();
                $("#createProject").modal("hide");
                isProcess = false;
              }, 700);
            });
        }
      }
    });
    $(document).on("click", ".edit-project", (event) => {
      event.preventDefault();
      idProject = $(event.currentTarget).data("id");
      $.ajax({
        url: `projects/${idProject}/render_edit`,
        type: "GET",
        data_type: "script",
        beforeSend: (xhr) => {
          const csrfToken = document.querySelector(
            "meta[name='csrf-token']"
          ).content;
          xhr.setRequestHeader("X-CSRF-Token", csrfToken);
        },
      });
    });

    $(document).on("click", ".create-project-btn", function (e) {
      $.ajax({
        url: `projects/render_create`,
        type: "GET",
        data_type: "script",
        beforeSend: (xhr) => {
          const csrfToken = document.querySelector(
            "meta[name='csrf-token']"
          ).content;
          xhr.setRequestHeader("X-CSRF-Token", csrfToken);
        },
      });
    });

    $(document).on("click", "#closeModal", (event) => {
      event.preventDefault();
      $("#name").val("");
      $("#description").val("");
      $(".error-name-content").text("");
      $(".error-application-content").text("");
      idProject = null;
    });

    $(document).on("click", "#delete-project", (event) => {
      event.preventDefault();
      idProject = $(event.currentTarget).data("id");
    });
    $(document).on("click", ".confirm-delete-project", (event) => {
      event.preventDefault();
      var eleBtn = $(".edit-project");
      eleBtn.each((index, element) => {
        $(element).addClass("disable-item__action");
      });
      $.ajax({
        url: `projects/${idProject}`,
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
          const messageSuccess = $("#deleteModal").data("delete-success");
          handleSucess(data ? data?.message : messageSuccess);
          setTimeout(() => {
            $("#deleteModal").modal("hide");
            window.location.reload();
            eleBtn.each((index, element) => {
              $(element).removeClass("disable-item__action");
            });
          }, 2000);
        })
        .fail(function (e) {
          handleError(e.responseJSON.error);
          setTimeout(() => {
            $("#deleteModal").modal("hide");
            window.location.reload();
          }, 2000);
        });
    });

    $(document).on("hidden.bs.modal", "#createProject", function () {
      var form = document.querySelector(".project-form");
      $("#name").val("");
      $("#description").val("");
      $(".error-name-content").text("");
      $(".error-application-content").text("");
      idProject = null;
      form.reset();
      $("#modal-title").removeAttr("data-action");
    });

    $(document).on(
      "change",
      "#choices-multiple-remove-button, #choices-multiple-members",
      function (e) {
        var managerList = $("#choices-multiple-remove-button").val() || [];
        var memberList = $(".role-member-list").val() || [];
        var action = $("#modal-title").data("action");
        var projectId = $("#modal-title").data("project");
        if (action == "edit") {
          $.ajax({
            url: `projects/${projectId}/render_user_project_role_edit`,
            type: "GET",
            data: {
              manager: managerList,
              member: memberList,
            },
            data_type: "script",
            beforeSend: (xhr) => {
              const csrfToken = document.querySelector(
                "meta[name='csrf-token']"
              ).content;
              xhr.setRequestHeader("X-CSRF-Token", csrfToken);
            },
          });
        } else {
          $.ajax({
            url: `projects/render_user_project_role_create`,
            type: "GET",
            data: {
              manager: managerList,
              member: memberList,
            },
            data_type: "script",
            beforeSend: (xhr) => {
              const csrfToken = document.querySelector(
                "meta[name='csrf-token']"
              ).content;
              xhr.setRequestHeader("X-CSRF-Token", csrfToken);
            },
          });
        }
      }
    );
  }
}
