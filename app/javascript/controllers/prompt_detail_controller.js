import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    let keysMessage, keysFunction, messageLength, functionLength;
    let valid_params = true;
    let userInput = [];
    let tagInput = [];
    function isBoolean(val) {
      return (
        val.trim().toLowerCase() === "false" ||
        val.trim().toLowerCase() === "true"
      );
    }

    function isPositiveInteger(val) {
      val = val.trim();
      if (!val) {
        return false;
      }
      val = val.replace(/^0+/, "") || "0";
      var n = Math.floor(Number(val));
      return n !== Infinity && String(n) === val && n >= 0;
    }

    function isInteger(val) {
      val = val.trim();
      if (!val) {
        return false;
      }
      val = val.replace(/^0+/, "") || "0";
      var n = Math.floor(Number(val));
      return n !== Infinity && String(n) === val;
    }

    function isPositiveFloat(val) {
      return !isNaN(val) && Number(val) >= 0;
    }

    function isFloatNumber(val) {
      return !isNaN(val);
    }

    function isValidMaxInteger(val, max) {
      return parseInt(val) <= max;
    }

    function isValidMinInteger(val, min) {
      return parseInt(val) >= min;
    }

    function isValidNumber(val, max) {
      return Number(val) <= max;
    }

    function isEmptyField(val) {
      return val == "" || val == undefined;
    }

    function handle_validate_params(max_tokens, api_type) {
      if ($("#prompt_name").val() == "") {
        $(".error-name-content").text("Prompt's Name can't be blank");
        valid_params = false;
      } else {
        $(".error-name-content").text("");
      }

      if ($("#endpoint_name").val() == "") {
        $(".error-endpoint_name-content").text(
          "Application endpoint name can't be blank"
        );
        valid_params = false;
      } else {
        $(".error-endpoint_name-content").text("");
      }

      if ($("#param_list").val() == "") {
        $(".error-name__config").text("This field can't be blank");
        valid_params = false;
      } else {
        $(".error-name__config").text("");
      }

      if (
        $("textarea#prompt").val() != undefined &&
        $("textarea#prompt").val().trim() == ""
      ) {
        $(".prompt-invalid").text("prompt parameter is required");
        valid_params = false;
      } else {
        if (
          (api_type == "image_generation" || api_type == "image_edit") &&
          $("textarea#prompt").val() != undefined &&
          $("textarea#prompt").val().length > 1000
        ) {
          $(".prompt-invalid").text("The maximum length is 1000 characters");
          valid_params = false;
        } else {
          $(".prompt-invalid").text("");
        }
      }

      if (isEmptyField($(".n").val()) || isInteger($(".n").val())) {
        if (api_type == "image_generation" || api_type == "image_edit") {
          if (
            isValidMinInteger($(".n").val(), 1) &&
            isValidMaxInteger($(".n").val(), 10)
          ) {
            $(".n-invalid").text("");
          } else {
            $(".n-invalid").text("n must be an integer between 1 and 10");
            valid_params = false;
          }
        } else {
          $(".n-invalid").text("");
        }
      } else {
        $(".n-invalid").text("n must be integer");
        valid_params = false;
      }

      if (
        isEmptyField($(".temperature").val()) ||
        (isPositiveFloat($(".temperature").val()) &&
          isValidNumber($(".temperature").val(), 2))
      ) {
        $(".temperature-invalid").text("");
      } else {
        $(".temperature-invalid").text(
          "temperature must be positive number and less than or equal to 2"
        );
        valid_params = false;
      }

      if (
        isEmptyField($(".top_p").val()) ||
        (isPositiveFloat($(".top_p").val()) &&
          isValidNumber($(".top_p").val(), 1))
      ) {
        $(".top_p-invalid").text("");
      } else {
        $(".top_p-invalid").text(
          "top-p must be positive number and less than or equal to 1"
        );
        valid_params = false;
      }

      if (
        isEmptyField($(".logprobs").val()) ||
        (isPositiveInteger($(".logprobs").val()) &&
          isValidMaxInteger($(".logprobs").val(), 5))
      ) {
        $(".logprobs-invalid").text("");
      } else {
        $(".logprobs-invalid").text(
          "logprobs must be positive integer and less than 5"
        );
        valid_params = false;
      }

      if (isEmptyField($(".stream").val()) || isBoolean($(".stream").val())) {
        $(".stream-invalid").text("");
      } else {
        $(".stream-invalid").text("stream must be boolean (true or false)");
        valid_params = false;
      }
      if (
        isEmptyField(max_tokens) ||
        isEmptyField($(".max_tokens").val()) ||
        (isPositiveInteger($(".max_tokens").val()) &&
          isValidMaxInteger($(".max_tokens").val(), max_tokens))
      ) {
        $(".max_tokens-invalid").text("");
      } else {
        $(".max_tokens-invalid").text(
          `max-tokens must be positive integer and less than ${max_tokens} with current model`
        );
        valid_params = false;
      }

      if (
        $("#functions_params_name").val() == undefined ||
        /^[\w-]{1,64}$/.test($("#functions_params_name").val())
      ) {
        $(".error-function-content").text("");
      } else {
        $(".error-function-content").text(
          "name must be a-z, A-Z, 0-9, or contain underscores and dashes, with a maximum length of 64"
        );
        valid_params = false;
      }

      if (
        $(".instruction").val() != undefined &&
        $(".instruction").val().trim() == ""
      ) {
        $(".instruction-invalid").text("instruction parameter is required");
        valid_params = false;
      } else {
        $(".instruction-invalid").text("");
      }

      if (checkFieldConfig().length) {
        var ErrorEle = $(".params-list");
        ErrorEle.each((index, element) => {
          let error;
          if (checkFieldConfig().includes(index)) {
            error = $(element).find(".error-name__config");
            error.text("Prompt config name can't be HTML code");
            valid_params = false;
          } else {
            error = $(element).find(".error-name__config");
            error.text("");
          }
        });
      }
      return valid_params;
    }

    function getConfigApiField() {
      const allTag = getALLTagFromUserInput() || [];
      const parameterList = allTag.join(" ");
      let tags = parameterList
        ?.match(/<([^>]+)>/g)
        ?.map((tag) => tag.slice(1, -1));
      $("#parameter_list").val(JSON.stringify(tags));
    }

    function checkFieldConfig() {
      let inputs = document.querySelectorAll(".matching_field");
      const temp_array = [];
      let index = 0;
      inputs.forEach((i) => {
        var chkEl = document.createElement("div");
        chkEl.innerHTML = i.value;
        if (i.value != "" && chkEl.getElementsByTagName("*").length) {
          temp_array.push(index);
        }
        index++;
      });
      return temp_array;
    }

    function getALLTagFromUserInput() {
      var parameterList = [];
      const listContent = document.querySelectorAll("#messages_params_content");
      const listMessageParName = document.querySelectorAll(
        "#messages_params_name"
      );
      const listMessageParFunC = document.querySelectorAll(
        "#messages_params_function_call"
      );
      const listFunctionName = document.querySelectorAll(
        "#functions_params_name"
      );
      const listFunctionDes = document.querySelectorAll(
        "#functions_params_description"
      );
      const listFunctionPar = document.querySelectorAll(
        "#functions_params_parameters"
      );
      const listParamsPrompt = document.querySelectorAll(
        ".completion_prompt_param"
      );

      listMessageParName.forEach(function (i) {
        var value = $(i).val();
        parameterList.push(value);
      });
      listMessageParFunC.forEach(function (i) {
        var value = $(i).val();
        parameterList.push(value);
      });
      listFunctionName.forEach(function (i) {
        var value = $(i).val();
        parameterList.push(value);
      });
      listFunctionDes.forEach(function (i) {
        var value = $(i).val();
        parameterList.push(value);
      });
      listFunctionPar.forEach(function (i) {
        var value = $(i).val();
        parameterList.push(value);
      });
      listContent.forEach(function (i) {
        var value = $(i).val();
        parameterList.push(value);
      });
      listParamsPrompt.forEach(function (i) {
        var value = $(i).val();
        parameterList.push(value);
      });

      return parameterList;
    }

    function getValueConfigApi(dom) {
      let inputs = document.querySelectorAll(dom);
      const main_array = [];
      const temp_array = [];
      inputs.forEach((i) => {
        temp_array.push(i.value.trim());
      });
      main_array.push(temp_array);
      return main_array;
    }

    function updateModalCompletion(parameter_list) {
      if (parameter_list == null) return;
      var listItems = "";
      if ($(".select-api option:selected").text() == "V1/Images/Edits") {
        listItems += `
        <div class="row mb-2">
          <div class="col-2">
            <div>Image</div>
          </div>
          <div class="col-10">
            <input type="text" name="image" class="image form-control" />
          </div>
        </div>
        <div class="row mb-2">
          <div class="col-2">
            <div>Mask</div>
          </div>
          <div class="col-10">
            <input type="text" name="mask" class="mask form-control" />
          </div>
        </div>`;
      }
      for (var i = 0; i < parameter_list.length; i++) {
        listItems +=
          `<div class="row mb-2"><div class="col-3"><div>` +
          parameter_list[i] +
          `</div></div><div class="col-9"><textarea id="userInputTest" rows="3" style="white-space: pre-line;" type="text" class="form-control api-config-field content-field__test message_params_${i}">${
            userInput[i] != undefined ? userInput[i] : ""
          }</textarea></div></div>`;
      }
      $("#listItems").html(listItems);
      const allTag = getALLTagFromUserInput()?.join(" ");
      const tagLength = allTag
        ?.match(/<([^>]+)>/g)
        ?.map((tag) => tag.slice(1, -1));
      userInput = new Array(tagLength?.length).fill("");
      let textarea = document.querySelectorAll("#userInputTest");
      textarea.forEach((i, idx) => {
        userInput[idx] = i.value;
        i.addEventListener("keyup", function () {
          userInput[idx] = i.value.trim();
        });
      });
      $(".prompt-test-result").html("");
    }

    $(function () {
      $(document).on("change", ".select-api", function (e) {
        const api_id = $(".select-api").val();
        const action = $(this).data("url");
        tagInput = [];
        $.ajax({
          beforeSend: (xhr) => {
            const csrfToken = document.querySelector(
              "meta[name='csrf-token']"
            ).content;
            xhr.setRequestHeader("X-CSRF-Token", csrfToken);
          },
          url: action,
          type: "GET",
          dataType: "script",
          data: {
            ai_api_id: api_id,
          },
        });
      });

      $(document).on("change", ".change-api", function (e) {
        const url = $(this).data("update-api-type-url");
        const prompId = $(this).data("prompt-id");
        const api_id = $(this).val();
        $.ajax({
          beforeSend: (xhr) => {
            const csrfToken = document.querySelector(
              "meta[name='csrf-token']"
            ).content;
            xhr.setRequestHeader("X-CSRF-Token", csrfToken);
          },
          url: url,
          type: "POST",
          dataType: "script",
          data: {
            ai_api_id: api_id,
            prompt_id: prompId
          },
        }).done((res) => {
          const type = $(".change-api").attr("data-api-type");
          changeTypeApi(type);
        });
      });

      $(document).on("change", ".select-model", function (e) {
        const url = $(this).data("url");
        const model = $(this).val();
        $.ajax({
          beforeSend: (xhr) => {
            const csrfToken = document.querySelector(
              "meta[name='csrf-token']"
            ).content;
            xhr.setRequestHeader("X-CSRF-Token", csrfToken);
          },
          url,
          type: "POST",
          dataType: "script",
          data: {
            model: model,
          },
        });
      });

      $(document).on("click", "#create-prompt", function (e) {
        e.preventDefault();
        getConfigApiField();
        let max_tokens = $(".select-model").attr("data-max-tokens");
        let api_type = $(".change-api").attr("data-api-type");
        $(this).addClass("disabled");
        window.scroll({
          top: 0,
          left: 0,
          behavior: "smooth",
        });
        valid_params = true;
        valid_params = handle_validate_params(max_tokens, api_type);

        if (valid_params) {
          $(".prompt-form").submit();
          $("#prompt-form").bind("ajax:complete", function () {
            $("#create-prompt").removeClass("disabled");
          });
        } else {
          $(this).removeClass("disabled");
        }
      });
      function changeTypeApi(type) {
        const chat_completion = $(".chat-completion-col");
        const completion = $(".completion-col");
        const edit = $(".edit-col");
        const image = $(".image-genaration");
        switch (type) {
          case "completion":
            edit.addClass("d-none");
            edit.removeClass("d-block");
            completion.addClass("d-block");
            completion.removeClass("d-none");
            chat_completion.removeClass("d-block");
            chat_completion.addClass("d-none");
            image.addClass("d-none");
            image.removeClass("d-block");
            break;
          case "chat_completion":
            edit.addClass("d-none");
            edit.removeClass("d-block");
            chat_completion.addClass("d-block");
            chat_completion.removeClass("d-none");
            completion.removeClass("d-block");
            completion.addClass("d-none");
            image.addClass("d-none");
            image.removeClass("d-block");
            break;
          case "edit":
            edit.addClass("d-block");
            edit.removeClass("d-none");
            chat_completion.removeClass("d-block");
            chat_completion.addClass("d-none");
            completion.removeClass("d-block");
            completion.addClass("d-none");
            image.addClass("d-none");
            image.removeClass("d-block");
            break;
          case "image_generation":
            edit.addClass("d-none");
            edit.removeClass("d-block");
            chat_completion.removeClass("d-block");
            chat_completion.addClass("d-none");
            completion.removeClass("d-block");
            completion.addClass("d-none");
            image.addClass("d-block");
            image.removeClass("d-none");
            break;
          case "image_edit":
            edit.addClass("d-none");
            edit.removeClass("d-block");
            chat_completion.removeClass("d-block");
            chat_completion.addClass("d-none");
            completion.removeClass("d-block");
            completion.addClass("d-none");
            image.addClass("d-block");
            image.removeClass("d-none");
          default:
            break;
        }
      }
      const api = $(".change-api").attr("data-api-type");
      changeTypeApi(api);
      $(document).on("click", "#save-prompt", function (e) {
        e.preventDefault();
        getConfigApiField();
        const formDom = document.getElementById("prompt-form");
        var formData = new FormData(formDom);
        const action = $(formDom).attr("action");
        let max_tokens = $(".select-model").attr("data-max-tokens");
        let api_type = $(".change-api").attr("data-api-type");
        $(this).addClass("disabled");
        valid_params = true;
        valid_params = handle_validate_params(max_tokens, api_type);
        if (valid_params) {
          $.ajax({
            url: action,
            data: formData,
            beforeSend: (xhr) => {
              const csrfToken = document.querySelector(
                "meta[name='csrf-token']"
              ).content;
              xhr.setRequestHeader("X-CSRF-Token", csrfToken);
            },
            type: "POST",
            dataType: "json",
            processData: false,
            contentType: false,
          })
            .done(function (response) {
              window.location.reload();
            })
            .fail(function (error) {
              const { redirect_url } = error?.responseJSON;
              window.location.href = redirect_url;
            });
        } else {
          $(this).removeClass("disabled");
        }
      });

      function renderResult(resultText, dom) {
        const textareaElement = $(dom);
        const typingEffectElement = $(
          '<textarea readonly class="w-100 border-0 col-12 flex-item-last mt-2 m-auto" style="outline:none; max-width: 98%;"></textarea>'
        ).addClass("typing-effect");
        if (textareaElement.length == 1) {
          textareaElement.append(typingEffectElement);
        } else {
          textareaElement.last().append(typingEffectElement);
        }

        let charIndex = 0;
        const typingInterval = setInterval(() => {
          typingEffectElement.text(
            typingEffectElement.text() + resultText[charIndex]
          );
          if (resultText.length < 40) {
            typingEffectElement.css("height", "30px");
          } else if (resultText.length > 40 && resultText.length < 100) {
            const height = charIndex * 0.7;
            typingEffectElement.css("height", height + "px");
          } else {
            const height = charIndex * 0.5;
            typingEffectElement.css("height", height + "px");
          }

          charIndex++;
          if (charIndex === resultText.length) {
            clearInterval(typingInterval);
            textareaElement.val(textareaElement.val() + resultText + "\n");
            textareaElement.scrollTop(textareaElement[0].scrollHeight);
          }
        }, 20);
      }


      $(document).on("click", ".run-test-ai, #test-prompt", function (e) {
        const self = this;
        const formDom = document.getElementById("prompt-form");
        var formData = new FormData(formDom);
        const action = $(formDom).attr("action");
        const requestName = getALLTagFromUserInput() || [];
        const listParams = requestName.join(" ");
        let tags = listParams
          ?.match(/<([^>]+)>/g)
          ?.map((tag) => tag.slice(1, -1));
        let uniqueTags = Array.from(new Set(tags));
        const requestValue = getValueConfigApi("#userTagInput")[0];
        let max_tokens = $(".select-model").attr("data-max-tokens");
        let api_type = $(".change-api").attr("data-api-type");
        valid_params = handle_validate_params(max_tokens, api_type);
        var textareaField = $(".content-field__test");
        textareaField.each((index, element) => {
          $(element).attr("disabled", "disabled");
        });
        $(".prompt-test-result-complete").addClass("hide-result__test");
        $(".prompt-test-result-complete").removeClass("show-result__test");
        $(".loading-test").removeClass("hide-loading__test");
        $(".loading-test").addClass("show-loading__test");
        $(".run-test-ai").addClass("disabled");
        $(".loader").removeClass("d-none");
        $(".prompt-error-response").remove();
        $(this).prop("disabled", true);
        const parameter_list = JSON.stringify(uniqueTags || "[]");
        const testInput = uniqueTags.map((val, index) => [
          val,
          requestValue[index],
        ]);
        const request_params = JSON.stringify(testInput || "[]");
        formData.append("request_params", request_params);
        formData.append("parameter_list", parameter_list);
        formData.append("image", $(".image").val());
        formData.append("mask", $(".mask").val());
        formData.append("_method", "POST");

        if (valid_params) {
          $.ajax({
            url: `${action}/run-test`,
            data: formData,
            beforeSend: (xhr) => {
              const csrfToken = document.querySelector(
                "meta[name='csrf-token']"
              ).content;
              xhr.setRequestHeader("X-CSRF-Token", csrfToken);
            },
            type: "POST",
            dataType: "json",
            processData: false,
            contentType: false,
          })
            .done(function (response) {
              const formatJson = JSON.stringify(
                response?.retult_test,
                undefined,
                4
              );
              textareaField.each((index, element) => {
                $(element).prop("disabled", false);
              });
              $(".prompt-test-result-complete").removeClass(
                "hide-result__test"
              );
              $(".prompt-test-result-complete").addClass("show-result__test");
              $(".loading-test").removeClass("show-loading__test");
              $(".loading-test").addClass("hide-loading__test");
              $(".run-test-ai").removeClass("disabled");
              const { api_type, retult_test } = response;
              $(".loader").addClass("d-none");
              $(self).removeAttr("disabled");
              if (api_type == "completion") {
                const { error } = retult_test;
                if (!error) {
                  let currentValue = $("#prompt").val();
                  const responseAi = retult_test?.choices?.map(
                    (vl) => vl["text"]
                  );
                  currentValue += responseAi;
                  $("#prompt").val(currentValue);
                } else {
                  const alertTemplate = `
                  <div class="prompt-error-response alert alert-danger d-flex align-items-center" role="alert" style="position: absolute; bottom: 180px; width: 95%">
                    <div>
                      ${error?.message}
                    </div>
                    </div>
                  `;
                  $("#prompt").after(alertTemplate);
                }
              }

              if (api_type == "chat_completion") {
                const { error } = retult_test;
                if (error) {
                  renderResult(error.message, ".message-field");
                } else {
                  const responseAi = retult_test?.choices?.map(
                    (vl) => vl["message"]["content"]
                  );
                  renderResult(responseAi && responseAi[0], ".message-field");
                }
              }
            })
            .fail(function (error) {
              console.log("error", error);
              $(".loader").addClass("d-none");
              $(self).removeAttr("disabled");
            });
        }
      });

      $(document).on("click", "#save-test", function (e) {
        const formDom = document.getElementById("prompt-form");
        var formData = new FormData(formDom);
        const action = $(formDom).attr("action");
        const promptTestResult = $(".prompt-test-result")[0].innerHTML;
        const requestName = getValueConfigApi(".matching_field")[0];
        const requestValue = getValueConfigApi(".api-config-field")[0];
        let max_tokens = $(".select-model").attr("data-max-tokens");
        let api_type = $(".change-api").attr("data-api-type");
        valid_params = handle_validate_params(max_tokens, api_type);
        requestName.pop();
        requestValue.pop();

        const parameter_list = JSON.stringify(requestName || "[]");
        const testInput = requestName.map((val, index) => [
          val,
          requestValue[index],
        ]);
        const request_params = JSON.stringify(testInput || "[]");
        formData.append("request_params", request_params);
        formData.append("parameter_list", parameter_list);
        formData.append("image", $(".image").val());
        formData.append("mask", $(".mask").val());
        formData.append("prompt_test_response", promptTestResult);
        if (valid_params) {
          $.ajax({
            url: `${action}/save-test`,
            data: formData,
            beforeSend: (xhr) => {
              const csrfToken = document.querySelector(
                "meta[name='csrf-token']"
              ).content;
              xhr.setRequestHeader("X-CSRF-Token", csrfToken);
            },
            type: "POST",
            dataType: "json",
            processData: false,
            contentType: false,
          })
            .done(function (response) {
              window.location.reload();
            })
            .fail(function (error) {
              console.log("error", error);
            });
        }
      });

      $(document).on("click", "#run-test-prompt", function (e) {
        e.preventDefault();
        var name = $("#prompt_name").val();
        $(".run-test-ai-modal").modal("show");
        $(".prompt-name-test").html(name);
        $(".loader").removeClass("d-none");
        $(".prompt-test-result-draft").addClass("d-none");
        getConfigApiField();
        const formDom = document.getElementById("prompt-form");
        var formData = new FormData(formDom);
        const action = $(formDom).attr("action");
        if ($(this).data("action") == "test-draft") {
          formData.append("test-draft", true);
        }
        let max_tokens = $(".select-model").attr("data-max-tokens");
        let api_type = $(".change-api").attr("data-api-type");
        valid_params = true;
        valid_params = handle_validate_params(max_tokens, api_type);

        if (valid_params) {
          $.ajax({
            url: `${action}/run-test-draft`,
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
          })
            .done(function (response) {
              const formatJson = JSON.stringify(
                response?.retult_test,
                undefined,
                4
              );
              $(".prompt-test-result-draft")
                .html(formatJson)
                .removeClass("d-none");
              $(".loader").addClass("d-none");
              $(".prompt-test-result-draft").removeClass("d-none");
              const paramAi = JSON.stringify(
                response?.param_test,
                undefined,
                4
              );
              $(".request-test-draft")
                .html(paramAi)
                .addClass("prompt-test-param-draft");
            })
            .fail(function (error) {
              console.log("error", error);
              $(".loader").addClass("d-none");
            });
        }
      });

      let timeoutInput, timeoutTag;

      function handleSendMessageWithKeyBoard(dom) {
        var inputElements = document.querySelectorAll(dom);
        inputElements.forEach(function (inputElement) {
          inputElement.addEventListener("keydown", function (event) {
            if (event.ctrlKey && event.keyCode === 13) {
              event.preventDefault();
              $("#test-prompt").click();
              $("#test-playground").click();
            }
          });
        });
      }

      $(document).on("click", "#test-playground", function (e) {
        const self = this;
        const formDom = document.getElementById("prompt-form");
        var formData = new FormData(formDom);
        const action = $(formDom).attr("action");
        const promptId = $(this).data("id");
        $(".prompt-test-result-complete").addClass("hide-result__test");
        $(".prompt-test-result-complete").removeClass("show-result__test");
        $(".loading-test").removeClass("hide-loading__test");
        $(".loading-test").addClass("show-loading__test");
        $(".loader").removeClass("d-none");
        $(".prompt-error-response").remove();
        $(this).prop("disabled", true);

        formData.append("image", $(".image").val());
        formData.append("mask", $(".mask").val());
        formData.append("_method", "POST");
        formData.append("prompt_id", promptId);

        $.ajax({
          url: `${action}`,
          data: formData,
          beforeSend: (xhr) => {
            const csrfToken = document.querySelector(
              "meta[name='csrf-token']"
            ).content;
            xhr.setRequestHeader("X-CSRF-Token", csrfToken);
          },
          type: "POST",
          dataType: "json",
          processData: false,
          contentType: false,
        })
          .done(function (response) {
            const formatJson = JSON.stringify(
              response?.retult_test,
              undefined,
              4
            );
            $(".prompt-test-result-complete").removeClass(
              "hide-result__test"
            );
            $(".prompt-test-result-complete").addClass("show-result__test");
            $(".loading-test").removeClass("show-loading__test");
            $(".loading-test").addClass("hide-loading__test");
            $(".run-test-ai").removeClass("disabled");
            const { api_type, retult_test } = response;
            $(".loader").addClass("d-none");
            $(self).removeAttr("disabled");
            if (api_type == "completion") {
              const { error } = retult_test;
              if (!error) {
                let currentValue = $("#prompt").val();
                const responseAi = retult_test?.choices?.map(
                  (vl) => vl["text"]
                );
                currentValue += responseAi;
                $("#prompt").val(currentValue);
              } else {
                const alertTemplate = `
                <div class="prompt-error-response alert alert-danger d-flex align-items-center" role="alert" style="position: absolute; bottom: 180px; width: 95%">
                  <div>
                    ${error?.message}
                  </div>
                  </div>
                `;
                $("#prompt").after(alertTemplate);
              }
            }

            if (api_type == "chat_completion") {
              const { error } = retult_test;
              if (error) {
                renderResult(error.message, ".message-field");
              } else {
                const responseAi = retult_test?.choices?.map(
                  (vl) => vl["message"]["content"]
                );
                renderResult(responseAi && responseAi[0], ".message-field");
              }
            }
          })
          .fail(function (error) {
            console.log("error", error);
            $(".loader").addClass("d-none");
            $(self).removeAttr("disabled");
          });
      });

      $(document).on('click', '.new-playground', function (e) {
        $.ajax({
          url: `/new_playground`,
          beforeSend: (xhr) => {
            const csrfToken = document.querySelector(
              "meta[name='csrf-token']"
            ).content;
            xhr.setRequestHeader('X-CSRF-Token', csrfToken);
          },
          type: 'POST',
          dataType: 'json'
        })
          .done(function (response) {
            const { new_playground } = response;
            window.location.href = new_playground;
          })
          .fail(function (error) {
            console.log('error', error);
          });
      });

      $(document).on('click', '.edit-playground', function (e) {
        $(this).closest('.chatbox-item').addClass('rename-on');
        $(this).closest('.chatbox-item').find('input').get(0).focus();
        const currentValue = $(this)
          .closest('.chatbox-item')
          .find('.chatbox-name')
          .text();
        $(this).closest('.chatbox-item').find('input').val(currentValue);
        $(this).addClass('d-none');
        $(this)
          .closest('.function-action')
          .find('i.remove-playground')
          .addClass('d-none');
        $(this)
          .closest('.function-action')
          .find('i.close-edit-playground')
          .removeClass('d-none');
        $(this)
          .closest('.function-action')
          .find('i.save-name-playground')
          .removeClass('d-none');
      });

      $(document).on('click', '.remove-playground', function (e) {
        $('#remove-playground').modal('show');
        const id = $('.chatbox-container').data('playground-current');
        $('.confirm-delete-playground').data('playground-delete', id);
      });

      $(document).on('click', '.confirm-delete-playground', function (e) {
        const id = $(this).data('playground-delete');
        $.ajax({
          url: `/delete_playground`,
          data: {
            id: id
          },
          beforeSend: (xhr) => {
            const csrfToken = document.querySelector(
              "meta[name='csrf-token']"
            ).content;
            xhr.setRequestHeader('X-CSRF-Token', csrfToken);
          },
          type: 'POST',
          dataType: 'json'
        })
          .done(function (response) {
            const { first_playground } = response;
              $(`[data-id-prompt="${id}"]`).remove();
              window.location.href = first_playground;
          })
          .fail(function (error) {
            console.log('error', error);
          });
      });

      $(document).on('blur', '.chatbox-item', function (e) {
        $(this).find('.function-action i.edit-playground').removeClass('d-none');
        $(this).find('.function-action i.remove-playground').removeClass('d-none');
        $(this).find('.function-action i.save-name-playground').addClass('d-none');
        $(this).find('.function-action i.close-edit-playground').addClass('d-none');
        $(this).removeClass('rename-on');
      });

      $(document).on('click', '.chatbox-item', function (e) {
        const self = this;
        const currentUrl = $('.chatbox-container').data('playground-current');
        const url = $(this).data('id-prompt');
        const promptName = $(this).closest('.chatbox-item').find('input').val();
        if (currentUrl != url) {
          window.location.href = url;
        }

        if ($(e.target).data('action') == 'change-playground') {
          $.ajax({
            url: `/update_playground`,
            data: {
              id: url,
              prompt_name: promptName
            },
            beforeSend: (xhr) => {
              const csrfToken = document.querySelector(
                "meta[name='csrf-token']"
              ).content;
              xhr.setRequestHeader('X-CSRF-Token', csrfToken);
            },
            type: 'POST',
            dataType: 'json'
          })
            .done(function (response) {
              const { new_name } = response;
              $(self)
                .closest('.chatbox-item')
                .find('.chatbox-name')
                ?.text(new_name);
            })
            .fail(function (error) {
              console.log('error', error);
            });
        }
      });


      $(document).on(
        "keyup",
        ".completion_prompt_param, #messages_params_content",
        function (e) {
          clearTimeout(timeoutInput);
          clearTimeout(timeoutTag);
          $(".prompt-error-response").remove();
          const userTyping = getALLTagFromUserInput()?.join(" ");
          const content = userTyping || "";
          timeoutInput = setTimeout(function () {
            let tags = content
              ?.match(/<([^>]+)>/g)
              ?.map((tag) => tag.slice(1, -1));
            let uniqueTags = Array.from(new Set(tags));
            if (uniqueTags && uniqueTags.length > 0) {
              var elements = document.querySelectorAll(".input-tag-complete");
              elements.forEach(function (element) {
                element.remove();
              });
              uniqueTags.forEach((i, idx) => {
                $(".tag-added").append(`
              <div class="m-2 input-tag-complete form-group" style="width: 95%;">
                <label class="text-truncate w-100" for="userTagInput">${
                  uniqueTags[idx]
                }:</label>
                <textarea class="form-control" type="text" id="userTagInput" value="${
                  tagInput[idx] != undefined ? tagInput[idx] : ""
                } rows="3"></textarea>
              </div>
            `);
              });
            } else {
              $(".input-tag-complete").remove();
            }
          }, 1000);

          let textarea = document.querySelectorAll("#userTagInput");
          textarea.forEach((i, idx) => {
            tagInput[idx] = i.value;
            i.addEventListener("keyup", function () {
              tagInput[idx] = i.value.trim();
            });
          });

          timeoutTag = setTimeout(function () {
            handleSendMessageWithKeyBoard('textarea[id="userTagInput"]');
          }, 1000);
        }
      );

      $(document).on('click', '.download-logs', function (e) {
        const url = $(this).data("url");
        const promptId = $(this).data("prompt");
        const keyword = $('#log-keyword').val();
        const startDate = $('#start_date').val();
        const endDate = $('#end_date').val();
        window.location.href = `${url}?prompt_id=${promptId}&keyword=${keyword}&start_date=${startDate}&end_date=${endDate}`;
      });

      $(document).on("click", "#reset-filters", function (e) {
        let ele = $(this).closest(".top-action").find(".input-blank__filter");
        ele.each((index, element) => {
          $(element).val("");
        });
      });

      $("#start_date").on("keydown", function (e) {
        e.preventDefault();
      });
      $("#start_date").on("keydown", function (e) {
        e.preventDefault();
      });

      // handle Ctrl+Enter

      handleSendMessageWithKeyBoard('textarea[id="messages_params_content"]');
      handleSendMessageWithKeyBoard(".completion_prompt_param");

      $(document).on("click", ".add-message", function (e) {
        handleSendMessageWithKeyBoard('textarea[id="messages_params_content"]');
      });
    });
  }
}
