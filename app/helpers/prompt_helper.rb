module PromptHelper
  def render_parameters parammeter
    parammeter.has_attribute?('value') ? parammeter&.value&.strip : parammeter.default_value&.strip
  end

  def get_max_token_value model
    max_token_value = { 'gpt-4': 8192, 'gpt-4-0613': 8192, 'gpt-4-32k': 32768, 'gpt-4-32k-0613': 32768, 'gpt-3.5-turbo': 4096,
      'gpt-3.5-turbo-0613': 4096, 'gpt-3.5-turbo-16k': 16384, 'gpt-3.5-turbo-16k-0613': 16384, 'text-davinci-003': 4097,
      'text-davinci-002': 4097, 'text-curie-001': 4097, 'text-babbage-001': 2049, 'text-ada-001': 2049 }

    max_token = max_token_value.keys.include?(model&.to_sym) ? max_token_value[model.to_sym] : 2049
  end

  def user_project_role
    return if current_user.nil? || current_user.admin? || @current_project.nil?

    user_project_role = @current_project.user_projects.find_by(user_id: current_user.id)
    user_project_role&.project_member?
  end
end
