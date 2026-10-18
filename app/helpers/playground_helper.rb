module PlaygroundHelper
  def current_user_playground_path
    return root_path unless current_user
    user_playground = current_user.prompts.where(project_id: nil)
    playground_target = if user_playground.present?
                    user_playground.first&.public_uid
                  else
                    init_api = AiApi.find_by(ai_type: 'chat_completion')
                    new_playground = Prompt.create!(
                                      ai_api: init_api,
                                      user_id: current_user.id,
                                      name: "New playground",
                                      model: init_api.model_list.last,
                                      endpoint_name: "playground")
                    new_playground&.public_uid
                  end
    Local_playground_path(playground_target)
  end
end
