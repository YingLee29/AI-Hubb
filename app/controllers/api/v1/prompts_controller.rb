class Api::V1::PromptsController < Api::V1::ApiBaseController
  def request_ai
    prompt_id = params[:id]
    endpoint_name = params[:endpoint_name]
    application_domain = request.referrer.nil? ? nil : URI.parse(request.referrer).origin
    key_string = request.headers['Authorization']&.split(' ')&.second
    remote_user_ip = request&.remote_ip
    prompt = Prompt.find_by(
      public_uid: prompt_id,
      endpoint_name: endpoint_name,
      project: Project.where(application_domain: application_domain).or(Project.where("ip_white_list LIKE ?", "%#{remote_user_ip}%"))
    )
    show_error(400, 'Bad request') and return if prompt.nil?

    key = prompt.keys.find_by(key_string: key_string)
    show_error(400, 'Bad request') and return if key.nil? || key.status == 'Deactive'

    log = Log.new(
      ip: request.remote_ip,
      user_agent: request.user_agent,
      api_endpoint: request.url,
      api_body: request.raw_post,
      prompt_id: prompt.id,
      project_id: prompt.project.id
    )
    file_params = params.permit(:image, :mask)
    result = CompletionApi.new(prompt, params[:request_params], file_params, log).call
    log.update(response: result.to_json)
    render json: {
      retult: result
    }, status: 200
  end
end
