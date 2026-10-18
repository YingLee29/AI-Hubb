module ChatHelper
  def current_user_chat_path
    return root_path unless current_user
    current_user_chat = current_user.chat_histories.where(prompt_id: nil)
    chat_target = if current_user_chat.present?
                    current_user_chat.first&.public_uid
                  else
                    new_chat = ChatHistory.create!(user_id: current_user&.id)
                    new_chat&.public_uid
                  end
    Local_id_chat_path(chat_target)
  end
end
