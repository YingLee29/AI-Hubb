class LanguageController < ApplicationController
  skip_before_action :authenticate_user!, only: :change

  def change
    language_change = params['language']
    current_language = session[:locale]
    return if current_language == language_change
    update_language_sync(language_change) if current_user
    I18n.locale = language_change&.to_sym
    set_session_and_redirect
  end

  private

  def set_session_and_redirect
    session[:locale] = I18n.locale

    respond_to do |format|
      format.json { render :json => {
        status: :ok
      } }
    end
  end

  def update_language_sync(lang)
    url = "#{ENV['Local_ID_BASE_URL']}/api/v1/change_language"
    HTTParty.post(url, body: { uid: session['x_user_id'], language: lang }.to_json, headers: { 'Content-Type': 'application/json'})
  end
end
