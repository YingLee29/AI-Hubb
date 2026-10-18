class Prompt < ApplicationRecord
  encrypts :public_uid, deterministic: true
  encrypts :model
  encrypts :parameter_list
  encrypts :endpoint_name, deterministic: true
  encrypts :description
  encrypts :prompt_test_response
  encrypts :messages_params
  encrypts :functions_params

  belongs_to :ai_api
  has_many :prompt_input_fields, dependent: :destroy
  has_many :keys, dependent: :destroy
  has_many :logs, dependent: :destroy
  belongs_to :project, optional: true
  belongs_to :user, optional: true
  accepts_nested_attributes_for :prompt_input_fields
  generate_public_uid generator: PublicUid::Generators::HexStringSecureRandom.new(20)
  serialize :prompt_test_response

  validates :name, presence: { message: ->(object, data) { "Prompt's Name can't be blank " } },
    length: { maximum: 255, message: ->(object, data) { "Prompt's Name is too long (maximum is 255 characters)" } }
  validates :endpoint_name, presence: { message: ->(object, data) { "Application endpoint name can't be blank " } },
    length: { maximum: 255, message: ->(object, data) { "Application endpoint name is too long (maximum is 255 characters)" } }

  delegate :ai_type, :completion_ai_type?, :chat_completion_ai_type?, :edit_ai_type?, :image_generation_ai_type?, :image_edit_ai_type?, to: :ai_api

  def to_param
    public_uid
  end

  def application_domain
    project.application_domain
  end

  def ip_white_list
    project.ip_white_list
  end

  def is_chat_completions?
    ai_api&.ai_type == "chat_completion"
  end

  def params_mapping(name, request_params)
    prompt_content = if public_uid.nil?
                      prompt_input_fields.find {|input| input.name == name}&.value
                     else
                      prompt_input_fields.find_by(name: name)&.value
                     end
    return '' if prompt_content.blank?

    replace_params(prompt_content, request_params)
  end

  def open_api_params(name)
    prompt_input = prompt_input_fields.find_by(name: name)
    case name
    when 'max_tokens'
      if self.chat_completion_ai_type?
        return '' if prompt_input.nil?
        prompt_input.value.to_i.zero? ? '' : prompt_input.value.to_i
      else
        prompt_input.nil? ? 16 : prompt_input.value.to_i
      end
    when 'temperature'
      temperature(prompt_input)
    when 'top_p'
      prompt_input.nil? ? 1 : prompt_input.value.to_f
    when 'n'
      prompt_input.nil? ? 1 : prompt_input.value.to_i
    when 'stream'
      false
    when 'logprobs'
      logprobs(prompt_input)
    when 'stop'
      stop(prompt_input)
    when 'size'
      prompt_input.nil? ? '1024x1024' : prompt_input.value
    when 'response_format'
      prompt_input.nil? ? 'url' : prompt_input.value
    when 'user'
      prompt_input.nil? ? '' : prompt_input.value
    end
  end

  def prompt_messages(request_params)
    return [{role: 'user', content: ''}] if messages_params.nil?
    messages_arr = eval(messages_params)
    messages_arr&.map do |message|
      content = replace_params(message['content'], request_params)
      if message['role'] == 'function'
        message_name = replace_params(message['name'], request_params)
        function_call = replace_params(message['function_call'], request_params)
        {
          role: message['role'],
          content: content,
          name: message_name,
          function_call: parse_content(function_call)
        }
      else
        {
          role: message['role'],
          content: content
        }
      end
    end
  end

  def prompt_functions(request_params)
    return [] if functions_params.nil?
    functions_arr = eval(functions_params)
    functions_arr&.map do |function|
      func_name = replace_params(function['name'], request_params)
      fun_description = replace_params(function['description'], request_params)
      fun_parameters = replace_params(function['parameters'], request_params)
      {
        name: func_name,
        description: fun_description,
        parameters: parse_content(fun_parameters)
      }
    end
  end

  def endpoint_url
    "#{ENV['DOMAIN_API']}/api/v1/prompts/#{self&.to_param}/#{self&.endpoint_name}"
  end

  private

  def replace_params(init_content, request_params)
    request_params&.each do |param, content|
      init_content&.gsub!("<#{param}>", content || '')
    end
    init_content
  end

  def parse_content(content)
    begin
      eval(content)
    rescue Exception
      content
    end
  end

  def temperature(prompt_input)
    return 1 if prompt_input.nil?

    value = prompt_input.value.to_f
    return 0 if value < 0

    value > 2 ? 2 : value
  end

  def stream(prompt_input)
    return false if prompt_input.nil?

    prompt_input.value.downcase == 'false' || prompt_input.value == '0' ? false : true
  end

  def logprobs(prompt_input)
    return nil if prompt_input.nil?

    value = prompt_input.value.to_i
    return nil if value <= 0

    value > 5 ? 5 : value
  end

  def stop(prompt_input)
    return '' if prompt_input.nil?

    JSON.parse(prompt_input.value)
  rescue JSON::ParserError
    prompt_input.value
  end
end
