import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="chat-gpt"

export default class extends Controller {
  connect() {
    let userResent = '';
    var isStopGenerating = false;
    var sendMessageAvariable = false;
    let waitting = false;
    hljs.initHighlightingOnLoad();
    $(document).ready(function () {
      function scrollToBottom() {
        var chatContainer = $('#chat-messages');
        chatContainer.animate(
          {
            scrollTop: chatContainer[0].scrollHeight
          },
          1000
        );
      }
      function addBotMessageWithTypingEffect(message) {
        var md = window.markdownit({
          html: true,
          linkify: true,
          typographer: true,
          breaks: false,
          langPrefix: 'language-',
          highlight: function (str, lang) {
            if (lang && hljs.getLanguage(lang)) {
              try {
                return (
                  '<pre class="hljs p-2 position-relative"><code>' +
                  hljs.highlight(str, { language: lang, ignoreIllegals: true })
                    .value +
                  '</code> <button class="hljs-copy hljs-copy-button">Copy</button>' +
                  '<button class="copy-done d-none btn"><i class="fa-solid fa-check"></i> Copied!</button></pre>'
                );
              } catch (__) {}
            }
            return (
              '<pre class="hljs"><code>' +
              md.utils.escapeHtml(str) +
              '</code></pre>'
            );
          }
        });
        var aiMessage = $(
          '<div class="ai-message"><span class="typing-indicator">🤖 </span></div>'
        );
        $('#chat-messages').append(aiMessage);

        let charIndex = 0;
        const typingInterval = setInterval(() => {
          aiMessage.text(aiMessage.text() + message[charIndex]);
          charIndex++;
          if (isStopGenerating) {
            clearInterval(typingInterval);
            $('.regenerate-btn').removeClass('d-none');
            $('.stop-regenerate-btn').addClass('d-none');
            isStopGenerating = false;
            return false;
          }
          $('.stop-regenerate-btn').removeClass('d-none');
          if (charIndex === message.length) {
            clearInterval(typingInterval);
            var html = md.render('<p><span>🤖</span>' + message + '</p>');
            aiMessage.html(html);
            $('#chat-messages').scrollTop($('#chat-messages')[0].scrollHeight);
            $('.regenerate-btn').removeClass('d-none');
            $('.stop-regenerate-btn').addClass('d-none');
            scrollToBottom();
          }
        }, 15);
      }

      // Hàm gửi tin nhắn
      function sendMessage(userInput) {
        waitting = false;
        const currentUrl = $('.chatbox-container').data('chat-current');
        const textarea = document.getElementById('user-input');
        const chatHChatContainer = document.getElementById('chat-messages');
        const promptId = $('#prompt-id').val();
        textarea.style.height = 48 + 'px';
        chatHChatContainer.style.minHeight = `calc(100vh - 275px)`;
        if (userInput.trim() !== '') {
          userResent = userInput;
          $('#chat-messages').append(
            '<div class="user-message" id="user-message"><span>👤</span>' + userInput + '</div>'
          );
          $('#user-input').val('');
          scrollToBottom();
          $('.regenerate-btn').addClass('d-none');
          $('.waiting-response').removeClass('d-none');
          $('#send-button').addClass('d-none');
          $('.chat-example').remove();
          $('.select-model').remove();
          $.ajax({
            url: `/chat_gpt`,
            data: {
              userInput: userInput,
              token: currentUrl,
              prompt_id: promptId
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
              const { bot_response } = response;
              if (bot_response) {
                addBotMessageWithTypingEffect(bot_response);
              } else {
                addBotMessageWithTypingEffect('Something went wrong');
              }
              $('.waiting-response').addClass('d-none');
              $('#send-button').removeClass('d-none');
            })
            .fail(function (error) {
              console.log('error', error);
            });
        }
      }
      $('#send-button').click(function () {
        var userInput = $('#user-input').val();
        if (sendMessageAvariable) {
          sendMessage(userInput);
        }
      });
      $('#user-input').keypress(function (event) {
        if (event.keyCode === 13 && sendMessageAvariable && !event.shiftKey) {
          var userInput = $('#user-input').val();
          sendMessage(userInput);
        }
      });

      $('.scroll-bottom').click(function () {
        scrollToBottom();
      });

      $(document).on('click', '.hljs-copy', function (event) {
        event.preventDefault();
        const dataCopy = $(this).closest('pre.hljs').find('code').text();
        var tempElement = document.createElement('input');
        tempElement.value = dataCopy;
        document.body.appendChild(tempElement);
        tempElement.select();
        tempElement.setSelectionRange(0, 99999);
        document.execCommand('copy');
        document.body.removeChild(tempElement);
        $(this).next().removeClass('d-none');
        $(this).addClass('d-none');
        setTimeout(() => {
          $(this).next().addClass('d-none');
          $(this).removeClass('d-none');
        }, 1000);
      });

      $(document).on('click', '.regenerate-btn', function (e) {
        if (userResent.length != 0) {
          sendMessage(userResent);
        }
      });

      $(document).on('click', '.stop-regenerate-btn', function (e) {
        isStopGenerating = true;
      });
      $(document).on('keyup', '#user-input', function (e) {
        const userInput = $(this).val();
        if (userInput.length != 0) {
          sendMessageAvariable = true;
          waitting = true;
          $('#send-button').addClass('send-avariable');
        } else {
          sendMessageAvariable = false;
          $('#send-button').removeClass('send-avariable');
        }
      });

      $(document).on('click', '.edit-chat', function (e) {
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
          .find('i.remove-chat')
          .addClass('d-none');
        $(this)
          .closest('.function-action')
          .find('i.close-edit-chat')
          .removeClass('d-none');
        $(this)
          .closest('.function-action')
          .find('i.save-name-chat')
          .removeClass('d-none');
      });

      $(document).on('click', '.remove-chat', function (e) {
        $('#remove-chat').modal('show');
        const token = $('.chatbox-container').data('chat-current');
        $('.confirm-delete-chat').data('chat-delete', token);
      });

      $(document).on('click', '.confirm-delete-chat', function (e) {
        const promptId = $('#prompt-id').val();
        const token = $(this).data('chat-delete');
        $.ajax({
          url: `/delete_chat`,
          data: {
            token: token
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
            if (promptId) {
              window.location.reload();
            } else {
              const { first_chat } = response;
              $(`[data-id-chat="${token}"]`).remove();
              window.location.href = first_chat;
            }
            end
          })
          .fail(function (error) {
            console.log('error', error);
          });
      });

      $(document).on('blur', '.chatbox-item', function (e) {
        $(this).find('.function-action i.edit-chat').removeClass('d-none');
        $(this).find('.function-action i.remove-chat').removeClass('d-none');
        $(this).find('.function-action i.save-name-chat').addClass('d-none');
        $(this).find('.function-action i.close-edit-chat').addClass('d-none');
        $(this).removeClass('rename-on');
      });

      $(document).on('click', '.chatbox-item', function (e) {
        const self = this;
        const currentUrl = $('.chatbox-container').data('chat-current');
        const url = $(this).data('id-chat');
        const chatName = $(this).closest('.chatbox-item').find('input').val();
        const promptId = $('#prompt-id').val();
        const projectId = $('#project-id').val();
        if (currentUrl != url) {
          if (promptId) {
            window.location.href = `/projects/${projectId}/prompts/${promptId}?chat_id=${url}#chat`;
          } else {
            window.location.href = url;
          }
        }

        if ($(e.target).data('action') == 'change-chat') {
          $.ajax({
            url: `/update_chat`,
            data: {
              token: currentUrl,
              chat_name: chatName
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

      $(document).on('click', '.new-chat', function (e) {
        const promptId = $('#prompt-id').val();
        const projectId = $('#project-id').val();
        console.log(promptId);
        $.ajax({
          url: `/new_chat`,
          data: {
            prompt_id: promptId
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
            const { new_chat } = response;
            if (promptId) {
              window.location.href = `/projects/${projectId}/prompts/${promptId}?chat_id=${new_chat}#chat`;
            } else {
              window.location.href = new_chat;
            }
          })
          .fail(function (error) {
            console.log('error', error);
          });
      });

      const chatContainer = document.querySelector('.chat-messages');
      chatContainer.addEventListener('scroll', function () {
        const scrollBot =
          chatContainer?.scrollHeight -
          chatContainer?.clientHeight -
          chatContainer?.scrollTop;
        if (scrollBot > 100) {
          $('.scroll-bottom').addClass('d-block');
          $('.scroll-bottom').removeClass('d-none');
        } else {
          $('.scroll-bottom').addClass('d-none');
          $('.scroll-bottom').removeClass('d-block');
        }
      });

      $(document).on('click', '.example-chat', function (e) {
        const chatText = $(this).text();
        $('#user-input').val(chatText);
        if (chatText.length) {
          $('#send-button').addClass('send-avariable');
          sendMessageAvariable = true;
        }
      });

      const chatModel = document.querySelectorAll('.btn-model');
      chatModel.forEach((i) => {
        i.addEventListener('click', function () {
          const currentUrl = $('.chatbox-container').data('chat-current');
          const model = $(this).data('model');
          const promptId = $('#prompt-id').val();
          const projectId = $('#project-id').val();
          $.ajax({
            url: `/update_model`,
            data: {
              token: currentUrl,
              model: model
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
              const { new_chat } = response;
              if (promptId) {
                window.location.reload();
              } else {
                window.location.href = new_chat;
              }
            })
            .fail(function (error) {
              console.log('error', error);
            });
        });
      });
      //auto scroll to bottom when loadpage
      scrollToBottom();

      const textarea = document.getElementById('user-input');
      const chatHChatContainer = document.getElementById('chat-messages');
      textarea.addEventListener('input', function (e) {
        const text = e.target.value;
        const new_line = text.split('\n');
        if (new_line.length > 1 && waitting) {
          this.style.height = 'auto';
          this.style.height = this.scrollHeight + 'px';
          chatHChatContainer.style.minHeight = `calc(100vh - ${
            275 + this.scrollHeight - 48
          }px)`;
        } else {
          this.style.height = 'auto';
          this.style.height = 48 + 'px';
          chatHChatContainer.style.minHeight = `calc(100vh - 275px)`;
          if (new_line.length == 2) {
            $('#user-input').val('');
          }
        }
      });
    });
  }
}
