class PromptsController < ApplicationController
  before_action :find_project
  before_action :check_accessable
  before_action :project_manager_role, only: %i[create update destroy new]
  before_action :strip_params, only: %i[create update]
  def index
    @keyword = params[:keyword]&.strip
    @search = @current_project.prompts.ransack(name_i_cont: @keyword)
    @prompts = @search.result.order(created_at: :desc).page(params[:page]).per(10)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    @prompt = Prompt.find_by!(public_uid: params[:id]) if params[:id].present?
    @keys = @prompt.keys.order(created_at: :desc).page(params[:page]).per(10)
    @ai_api = AiApi.api_available
    @parameter_list = @prompt.prompt_input_fields
    if params[:ai_api_id].present?
      @ai_api_target = AiApi.find_by(public_uid: params[:ai_api_id])
      @model_list = @ai_api_target&.model_list&.map(&:strip)
      @parameter_list = @ai_api_target&.ai_api_input_fields if @prompt.ai_api_id != @ai_api_target.id
      @prompt.ai_api = @ai_api_target
    else
      @model_list = @prompt.ai_api&.model_list&.map(&:strip)
    end

    @keyword = params[:keyword]

    @start_date = params[:start_date]
    @end_date = params[:end_date]

    start_date = Time.zone.parse(params[:start_date]) if params[:start_date].present?
    end_date = Time.zone.parse(params[:end_date]) if params[:end_date].present?


    if start_date && end_date
      @log_range = @prompt.logs.where(created_at: start_date..end_date)
    elsif start_date
      @log_range = @prompt.logs.where(created_at: start_date..Time.zone.now)
    elsif end_date
      first_log = @prompt.logs.order(:created_at).first&.created_at
      @log_range = @prompt.logs.where(created_at: first_log..end_date)
    else
      @log_range = @prompt.logs
    end

    @search = @log_range.ransack(ip_or_user_agent_or_api_endpoint_or_api_body_or_ai_endpoint_or_ai_body_or_response_i_cont: @keyword)
    @logs = @search.result.order(created_at: :desc).page(params[:page]).per(10)
    @prompt_id = @prompt.to_param
    @project_id = @prompt.project.to_param
    @user_history_chat = current_user.chat_histories.where(prompt_id: @prompt.id)
    @current_chat = @user_history_chat.find_by(public_uid: params[:chat_id])
    if params[:chat_id].present? && @current_chat.present?
      @user_chat_content = @current_chat&.metadata
      @response_ai = @user_chat_content&.map { |item| item['bot_response'] }
    else
      @current_chat, @user_history_chat, @user_chat_content, @response_ai = current_user.target_chat_history(@prompt)
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  def update
    @api_domain = ENV['DOMAIN_API']
    prompt = Prompt.find_by(public_uid: params[:id])
    raise ActiveRecord::RecordNotFound unless prompt.present?

    ai_api = AiApi.find_by(public_uid: params[:ai_api_id])
    raise ActiveRecord::RecordNotFound unless ai_api.present?
    params[:ai_api_id] = ai_api.id
    input_fields = params[:prompt_input_fields]&.values || []
    fields_list = JSON.parse params[:parameter_list] if params[:parameter_list].present?
    ActiveRecord::Base.transaction do
      prompt.prompt_input_fields.destroy_all
      prompt.update!(prompts_params)
      prompt.update(prompt_input_fields_attributes: input_fields, parameter_list: fields_list)

      flash[:alert] = I18n.t('views.prompt.modal.update_successfully')
      respond_to do |format|
        format.json { render :json => {
          new_prompt: prompt,
          errors: prompt.errors
        }, status: 200 }
      end
    end
  rescue ActiveRecord::RecordNotFound
    render json: {
      error: "Data is not found",
      redirect_url: project_prompts_path
    }, status: 404
  rescue => e
    respond_to do |format|
      format.json { render :json => {
        new_prompt: prompt,
        errors: prompt.errors,
        ai_type: prompt.ai_type,
      }}
    end
  end

  def destroy
    prompt = Prompt.find_by!(public_uid: params[:id])
    prompt.destroy!
    @success = true
    @message = I18n.t('views.prompt.modal.detele_successfully')
  end

  def new
    @api_domain = ENV['DOMAIN_API']
    @ai_apis = AiApi.api_available
    @init_api = @ai_apis.find_by(ai_type: 'chat_completion')
    @prompt = Prompt.new(ai_api: @init_api, project: @current_project)
    raise ActiveRecord::RecordNotFound if @prompt.blank?

    if params[:ai_api_id].present?
      @ai_api_target = AiApi.find_by(public_uid: params[:ai_api_id])
      @model_list = @ai_api_target&.model_list&.map(&:strip)
      @parameter_list = @ai_api_target&.ai_api_input_fields
      @prompt.ai_api = @ai_api_target
    else

      @model_list = @init_api&.model_list&.map(&:strip)
      @parameter_list = @init_api&.ai_api_input_fields
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    ai_api = AiApi.find_by(public_uid: params[:ai_api_id])
    raise ActiveRecord::RecordNotFound if ai_api.blank?

    ai_api_id = ai_api.id
    project_id = @current_project.id
    prompt_input_fields_attributes = params[:prompt_input_fields]&.values || {}
    if ai_api&.ai_type != 'chat_completion'
      prompt_input_fields_attributes.map! do |field|
        if field['name'] == 'prompt'
          {'name' => 'prompt', 'value' => ''}
        else
          field
        end
      end
    end
    ActiveRecord::Base.transaction do
      fields_list = params[:parameter_list].present? ? JSON.parse(params[:parameter_list]) : {}
      @prompt = Prompt.create!(prompts_params.merge(ai_api_id:, project_id:, parameter_list: fields_list, prompt_input_fields_attributes:))
      flash[:alert] = I18n.t('views.prompt.modal.create_successfully')
    end

    redirect_to project_prompt_path(@current_project, @prompt)
  rescue ActiveRecord::RecordNotFound
    render json: {
      error: "Data is not found"
    }, status: 404
  end

  def run_test
    ai_api = AiApi.find_by(public_uid: prompt_params[:ai_api_id])
    prompt = Prompt.new(prompt_params.except(
      :endpoint_url, :image, :mask, :request_params
    ).merge(ai_api_id: ai_api.id, project_id: @current_project.id))
    input_fields = params[:prompt_input_fields]&.values || []
    prompt.assign_attributes(prompt_input_fields_attributes: input_fields)
    request_params = JSON.parse prompt_params[:request_params]
    file_params = prompt_params.permit(:image, :mask)
    retult_test = CompletionApi.new(prompt, request_params, file_params, nil, input_fields).call

    respond_to do |format|
      format.json { render :json => {
        retult_test: retult_test,
        api_type: prompt.ai_type
      }, status: 200 }
    end
  end

  def run_test_draft
    prompt = Prompt.find_by!(public_uid: params[:id])
    prompt_clone = prompt.dup
    ai_api = AiApi.find_by(public_uid: params[:ai_api_id])
    raise ActiveRecord::RecordNotFound unless ai_api.present?

    params[:ai_api_id] = ai_api.id
    input_fields = params[:prompt_input_fields]&.values || []

    prompt_clone.prompt_input_fields.destroy_all
    prompt_clone.assign_attributes(prompts_params)
    prompt_clone.assign_attributes(prompt_input_fields_attributes: input_fields)
    request_params = JSON.parse params[:request_params] if params[:request_params].present?
    message_params = JSON.parse(params[:messages_params].to_json) if params[:messages_params].present?
    retult_test = CompletionApi.new(prompt_clone, request_params, nil, nil, input_fields).call
    respond_to do |format|
      format.json { render :json => {
        param_test: {model: prompt_clone.model, messages: message_params},
        retult_test: retult_test,
      }, status: 200 }
    end
  end

  def save_test
    @api_domain = ENV['DOMAIN_API']
    prompt = Prompt.find_by(public_uid: params[:id])
    ai_api = AiApi.find_by(public_uid: prompt_params[:ai_api_id])
    prompt_test_response = params[:prompt_test_response].present? ? JSON.parse(params[:prompt_test_response]) : {}
    input_fields = params[:prompt_input_fields]&.values || []
    prompt.prompt_input_fields.destroy_all

    prompt_params_to_update = prompt_params.except(:endpoint_url, :image, :mask, :request_params).merge(ai_api_id: ai_api.id, project_id: @current_project.id)

    prompt_params_to_update[:prompt_test_response] = JSON.parse(params[:prompt_test_response]) if params[:prompt_test_response].present?

    prompt.update!(prompt_params_to_update)

    prompt.update(prompt_input_fields_attributes: input_fields)
  end

  def update_max_tokens
    @new_max_token =  params[:model].present? ? get_max_token_value(params[:model]) : 2049
  end

  def update_api_type
    @api_type = AiApi.find_by(public_uid: params[:ai_api_id])&.ai_type
    @api_type.present? ? @api_type : "chat_completion"
  end

  private

  def prompts_params
    temp_params = params.permit(:name, :ai_api_id, :model, :application_domain, :endpoint_name, :description,
      messages_params: [[:role, :content, :name, :function_call]], functions_params: [[:name, :description, :parameters]])
    temp_params[:messages_params] = temp_params[:messages_params]&.map { |message| message.to_h }
    temp_params[:functions_params] = temp_params[:functions_params]&.map { |message| message.to_h }
    temp_params
  end

  def strip_params
    params.each do |key, value|
      value.strip! if value.is_a?(String) && %w[name description endpoint_name].include?(key)
    end
  end

  def find_project
    @current_project = current_tenant.projects.find_by!(public_uid: params[:project_id])
  end

  def check_accessable
    return if current_user.admin?
    raise ActiveRecord::RecordNotFound unless current_user.projects.pluck(:id).include?(@current_project&.id)
  end

  def build_end_point_url(prompt)
    "#{ENV['DOMAIN_API']}/api/v1/prompts/#{prompt&.to_param}/#{prompt&.endpoint_name}"
  end

  def project_manager_role
    return if current_user.admin?
    user_project_role = @current_project.user_projects.find_by(user_id: current_user.id)
    raise ActiveRecord::RecordNotFound if user_project_role&.project_member?
  end

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
