class ApplicationController < ActionController::Base
  include ApplicationHelper
  include PromptHelper
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!
  set_current_tenant_through_filter
  before_action :check_login
  before_action :set_tenant
  before_action :set_locale

  #rescue_from Exception, with: :internal_server_error
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::BadRequest, with: :bad_request
  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in, keys: [:email, :password])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :email, :phone, :gender, :role, :password])
  end

  def internal_server_error
    redirect_to '/500'
  end

  def not_found
    redirect_to '/404'
  end

  def bad_request
    redirect_to '/400'
  end

  def set_tenant
    set_current_tenant(current_user.company) if current_user
  end

  def set_locale
    I18n.locale = extract_locale || I18n.default_locale
  end

  def extract_locale
    I18n.locale = if session['x_user_id'].present?
                    fetch_language
                  else
                    session[:locale] || I18n.default_locale
                  end
    session[:locale] = I18n.locale
    @current_language = I18n.locale
  end

  def fetch_language
    url = "#{ENV['Local_ID_BASE_URL']}/api/v1/lang"

    response = HTTParty.get(url, body: { uid: session['x_user_id'] }.to_json, headers: { 'Content-Type': 'application/json'})
    response.dig('lang') || 'en'

  end

  def check_login
    url = "#{ENV['Local_ID_BASE_URL']}/api/v1/is_login"

    response = HTTParty.get(url, body: { user: current_user&.email }.to_json, headers: { 'Content-Type': 'application/json'})
    user_login = response.dig('login', 'online')
    return if current_user.nil?
    sign_out current_user unless user_login
  end
end
