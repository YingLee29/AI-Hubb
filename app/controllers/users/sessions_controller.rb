# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]
  before_action :login_with_Local_link, only: [:new]
  before_action :last_login

  layout "layouts/login_layout"

  def destroy
    sign_out(resource_name)
    sync_logout
    redirect_to new_user_session_path
  end

  private
    def login_with_Local_link
      @login_path = "#{ENV['Local_ID_BASE_URL']}/api/v1/oauth2/authorize?service_id=#{ENV['SERVICE_ID']}&client_id=#{ENV['CLIENT_ID']}&response_type=code"
    end

    def last_login
      @last_login = current_user&.email
    end

    def sync_logout
      url = "#{ENV['Local_ID_BASE_URL']}/api/v1/user_logout"

      HTTParty.post(url, body: { user: @last_login }.to_json, headers: { 'Content-Type': 'application/json'})
      reset_session
      return
    end
end
