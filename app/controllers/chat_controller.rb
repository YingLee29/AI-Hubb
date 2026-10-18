require 'csv'
class ChatController < ApplicationController
  before_action :authenticate_user!

  layout 'chat_gpt_layout'
  def chat
    @current_chat = ChatHistory.find_by(public_uid: params[:token])
    @user_history_chat = current_user.chat_histories.where(prompt_id: nil)
    @user_chat_content = @current_chat&.metadata
    @response_ai = @user_chat_content&.map { |item| item['bot_response'] }
  end

  def chat_history
    @current_chat = ChatHistory.find_by(public_uid: params[:token])&.metadata
    @response_ai = @current_chat&.map { |item| item['bot_response'] }

    render json: { chat_history: @response_ai}
  end

  def chat_gpt
    user_input = params['userInput']
    prompt = Prompt.find_by(public_uid: params['prompt_id'])
    if prompt.present?
      list_message = prompt.messages_params && eval(prompt.messages_params)
      system_message = list_message&.select {|a| a.dig('role') == 'system'}&.dig(-1, 'content')
    else
      system_message = "You are a helpful assistant."
    end
    current_chat = ChatHistory.find_by(public_uid: params[:token])
    client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
    context = current_chat.chat_context&.presence || system_message
    model = current_chat.default_models.presence || "gpt-3.5-turbo"
    response = client.chat(
      parameters: {
        model: model,
        messages: [
          { role: "system", content: context},
          { role: "user", content: user_input }
        ],
        temperature: 1,
    })
    bot_response =  response.dig("choices", 0, "message", "content")&.strip
    if current_chat.chat_context&.bytesize.to_f/1024 > 4
      current_chat.update!(chat_context: "")
    else
      context += bot_response.presence || ''
      current_chat.update!(chat_context: context)
    end
    current_chat.metadata = current_chat.metadata << {'user_request' => user_input, 'bot_response' => bot_response}
    current_chat.save!
    render json: { bot_response: }
  rescue => exception
    response = bot_response.presence || 'Something went wrong'
    current_chat.update!(metadata: [])
    render json: { bot_response: response }
  end

  def new_chat
    prompt = Prompt.find_by(public_uid: params['prompt_id'])
    @new_chat = ChatHistory.create!(user_id: current_user&.id, prompt_id: prompt&.id)
    render json: { new_chat:  @new_chat&.public_uid}
  end

  def update_chat
    new_name = params['chat_name']
    current_chat = ChatHistory.find_by(public_uid: params[:token])
    current_chat&.update(chat_name: new_name) if current_chat.present?

    render json: { new_name:  current_chat&.chat_name}
  end

  def update_model
    model = params['model']
    current_chat = ChatHistory.find_by(public_uid: params[:token])
    current_chat&.update(default_models: model) if current_chat.present?
    render json: { new_chat: current_chat&.public_uid}
  end

  def delete_chat
    current_chat = ChatHistory.find_by(public_uid: params[:token])
    current_chat.destroy if current_chat.present?
    prompt = Prompt.find_by(public_uid: params['prompt_id'])
    current_user_chats = current_user.chat_histories.where(prompt_id: prompt&.id)
    first_chat = if current_user_chats.present?
                  current_user_chats.first
                else
                  ChatHistory.create!(user_id: current_user&.id, prompt_id: prompt&.id)
                end
    render json: { first_chat:  first_chat&.public_uid}
  end

  def download_csv
    current_chat = ChatHistory.find_by(public_uid: params[:token])
    user_chat_content = current_chat&.metadata
    csv_data = CSV.generate do |csv|
      csv << ['Role', 'Content']
      user_chat_content.each do |con|
        con.map do |key, val|
          role = key == "user_request" ? "User request" : "Bot response"
          csv << [role, val]
        end
      end
    end
    send_data csv_data, type: 'text/csv; charset=utf-8; header=present', disposition: "attachment; filename=#{current_chat.chat_name}.csv"
  end

  def upload_file
    current_chat = ChatHistory.find_by(public_uid: params[:token])

    if prompt.present?
      list_message = prompt.messages_params && eval(prompt.messages_params)
      system_message = list_message&.select {|a| a.dig('role') == 'system'}&.dig(-1, 'content')
    else
      system_message = "You are a helpful assistant."
    end

    if current_chat.chat_context&.bytesize.to_f/1024 > 4
      current_chat.update!(chat_context: "")
    else
      context += bot_response.presence || ''
      current_chat.update!(chat_context: context)
    end

    current_chat.update!(chat_context: context)
    current_chat.save!
  end
end
