require 'multibyte'

class CompletionApi
  def initialize(prompt, request_params, file_params, log = nil, draft = nil)
    @prompt = prompt
    @file_params = file_params
    @request_params = request_params
    @log = log
    @draft = draft
  end

  def call
    client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
    if @prompt.completion_ai_type?
      completion(client)
    elsif @prompt.chat_completion_ai_type?
      chat_completion(client)
    elsif @prompt.image_generation_ai_type?
      image_generate(client)
    elsif @prompt.image_edit_ai_type?
    begin
      image_edit(client)
    rescue Down::Error
      { error: 'Invalid url' }
    end
    else
      edit(client)
    end
  end

  private

  def get_max_token_value model
    max_token_value = { 'gpt-4': 8192, 'gpt-4-0613': 8192, 'gpt-4-32k': 32768, 'gpt-4-32k-0613': 32768, 'gpt-3.5-turbo': 4096,
      'gpt-3.5-turbo-0613': 4096, 'gpt-3.5-turbo-16k': 16384, 'gpt-3.5-turbo-16k-0613': 16384, 'text-davinci-003': 4097,
      'text-davinci-002': 4097, 'text-curie-001': 4097, 'text-babbage-001': 2049, 'text-ada-001': 2049 }

    max_token = max_token_value.keys.include?(model&.to_sym) ? max_token_value[model.to_sym] : 2049
  end

  def completion(client)
    max_tokens = if @draft.present?
                    this_value = @draft.find { |item| item["name"] == "max_tokens" }["value"]
                    this_value.present? ? this_value.to_i : nil
                  else
                    @prompt.open_api_params('max_tokens')
                  end

    ai_prompt = @prompt.params_mapping('prompt', @request_params)
    token_used = ai_prompt.mb_chars&.length
    token_rest = if token_used.nil?
                    max_tokens
                  else
                    get_max_token_value(@prompt.model) - (token_used * 1.4)&.round
                  end
    parameters = {
      model: @prompt.model,
      prompt: ai_prompt,
      max_tokens: token_rest,
      temperature: @prompt.open_api_params('temperature'),
      top_p: @prompt.open_api_params('top_p'),
      n: @prompt.open_api_params('n'),
      stream: @prompt.open_api_params('stream'),
      logprobs: @prompt.open_api_params('logprobs'),
      stop: @prompt.open_api_params('stop')
    }
    @log.update(ai_body: parameters.to_json, ai_endpoint: 'https://api.openai.com/v1/completions') if @log.present?
    client.completions(parameters: parameters)
  end

  def chat_completion(client)
    @log.update(ai_endpoint: 'https://api.openai.com/v1/chat/completions') if @log.present?
    functions = @prompt.prompt_functions(@request_params)
    max_tokens = if @draft.present?
                  this_value = @draft.find { |item| item["name"] == "max_tokens" }["value"]
                  this_value.present? ? this_value.to_i : nil
                else
                  @prompt.open_api_params('max_tokens')
                end

    parameters = {
      model: @prompt.model,
      messages: @prompt.prompt_messages(@request_params),
      temperature: @prompt.open_api_params('temperature'),
      top_p: @prompt.open_api_params('top_p'),
      n: @prompt.open_api_params('n'),
      stream: @prompt.open_api_params('stream'),
      stop: @prompt.open_api_params('stop')
    }
    parameters = parameters.merge(max_tokens: max_tokens) if max_tokens.present?
    @log.update(ai_body: parameters.to_json) if @log.present?
    return client.chat(parameters: parameters) if functions.empty?
    @log.update(ai_body: parameters.merge(functions: functions).to_json) if @log.present?
    client.chat(parameters: parameters.merge(functions: functions))
  end

  def image_generate(client)
    user = @prompt.open_api_params('user')
    parameters = {
      prompt: @prompt.params_mapping('prompt', @request_params),
      n: @prompt.open_api_params('n'),
      size: @prompt.open_api_params('size'),
      response_format: @prompt.open_api_params('response_format'),
    }
    parameters.merge(user: user) if user.present?
    @log.update(ai_body: parameters.to_json, ai_endpoint: 'https://api.openai.com/v1/images/generations') if @log.present?
    client.images.generate(parameters: parameters)
  end

  def image_edit(client)
    user = @prompt.open_api_params('user')
    parameters = {
      image: Down.download(@file_params['image']).path,
      prompt: @prompt.params_mapping('prompt', @request_params),
      n: @prompt.open_api_params('n'),
      size: @prompt.open_api_params('size'),
      response_format: @prompt.open_api_params('response_format'),
    }
    parameters.merge(mask: Down.download(@file_params['mask']).path) if @file_params['mask'].present?
    parameters.merge(user: user) if user.present?
    @log.update(ai_body: parameters.to_json, ai_endpoint: 'https://api.openai.com/v1/images/edits') if @log.present?
    client.images.edit(parameters: parameters)
  end

  def edit(client)
    parameters = {
      model: @prompt.model,
      input: @prompt.params_mapping('input', @request_params),
      instruction: @prompt.params_mapping('instruction', @request_params),
      n: @prompt.open_api_params('n'),
      top_p: @prompt.open_api_params('top_p'),
      temperature: @prompt.open_api_params('temperature'),
    }
    @log.update(ai_body: parameters.to_json, ai_endpoint: 'https://api.openai.com/v1/edits') if @log.present?
    client.edits(parameters: parameters)
  end
end
