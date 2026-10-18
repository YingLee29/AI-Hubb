class PlaygroundController < ApplicationController
  before_action :authenticate_user!

  def index
    @user_playground = current_user.prompts.where(project_id: nil)
    @prompt = @user_playground.find_by(public_uid: params[:prompt_id])
    @api_domain = ENV['DOMAIN_API']
    @ai_apis = AiApi.api_available
    @parameter_list = @prompt&.prompt_input_fields
    if params[:ai_api_id].present?
      @ai_api_target = AiApi.find_by(public_uid: params[:ai_api_id])
      @model_list = @ai_api_target&.model_list&.map(&:strip)
      if @prompt&.ai_api_id != @ai_api_target.id || @parameter_list.blank?
        @parameter_list = @ai_api_target&.ai_api_input_fields
      end
      @prompt&.ai_api = @ai_api_target
    else
      @model_list = @prompt&.ai_api&.model_list&.map(&:strip)
      @parameter_list = @prompt&.ai_api&.ai_api_input_fields if @parameter_list.blank?
    end
  end

  def new_playground
    init_api = AiApi.find_by(ai_type: 'chat_completion')
    new_playground = Prompt.create!(
                      ai_api: init_api,
                      user_id: current_user.id,
                      name: "New playground",
                      model: init_api.model_list.last,
                      endpoint_name: "playground")
    render json: { new_playground:  new_playground&.public_uid}
  end

  def update_playground
    new_name = params['prompt_name']
    prompt = Prompt.find_by(public_uid: params[:id])
    prompt.update(name: new_name) if prompt.present?

    render json: { new_name:  prompt&.name}
  end

  def delete_playground
    prompt = Prompt.find_by(public_uid: params[:id])
    prompt.destroy if prompt.present?
    current_user_playground = current_user.prompts.where(project_id: nil)
    first_playground = if current_user_playground.present?
                  current_user_playground.first
                else
                  init_api = AiApi.find_by(ai_type: 'chat_completion')
                  Prompt.create!(
                      ai_api: init_api,
                      user_id: current_user.id,
                      name: "New playground",
                      model: init_api.model_list.last,
                      endpoint_name: "playground")
                end
    render json: { first_playground:  first_playground&.public_uid}
  end

  def update_api_type
    @init_api = AiApi.find_by(public_uid: params[:ai_api_id])
    @api_type = @init_api&.ai_type
    @model_list = @init_api&.model_list&.map(&:strip)
    @prompt = Prompt.find_by(public_uid: params[:prompt_id])
    @user_playground = current_user.prompts.where(project_id: nil)
    @parameter_list = @prompt&.prompt_input_fields
    if @prompt.ai_api_id != @init_api&.id || @parameter_list.blank?
      @parameter_list = @init_api&.ai_api_input_fields
    end
    @prompt.ai_api_id = @init_api&.id
    @api_type.present? ? @api_type : "chat_completion"
  end

  def update_max_tokens
    @new_max_token =  params[:model].present? ? get_max_token_value(params[:model]) : 2049
  end

  def run_test
    ai_api = AiApi.find_by(public_uid: prompt_params[:ai_api_id])
    prompt = Prompt.find_by(public_uid: params[:prompt_id])
    prompt.update(prompt_params.except(
      :endpoint_url, :image, :mask, :request_params
    ).merge(ai_api_id: ai_api.id))
    input_fields = params[:prompt_input_fields]&.values || []
    prompt.prompt_input_fields.destroy_all
    prompt.update(prompt_input_fields_attributes: input_fields)
    request_params = prompt_params[:request_params].nil? ? [] : JSON.parse(prompt_params[:request_params])
    file_params = prompt_params.permit(:image, :mask)
    retult_test = CompletionApi.new(prompt, request_params, file_params, nil, input_fields).call
    respond_to do |format|
      format.json { render :json => {
        retult_test: retult_test,
        api_type: prompt.ai_type
      }, status: 200 }
    end
  end

  private

  def prompt_params
    params.permit(
      :name,
      :ai_api_id,
      :model,
      :parameter_list,
      :description,
      :endpoint_name,
      :endpoint_url,
      :image,
      :mask,
      :project_id,
      :request_params,
      messages_params: [:role, :content, :name, :function_call],
    )
  end
end
