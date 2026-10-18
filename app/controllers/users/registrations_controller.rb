# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]
  before_action :authenticate_user!, only: :edit

  def update_resource(resource, account_params)
    if params.dig(:user, :type) == "update_password"
      resource.update_with_password(account_params)
    else
      resource.update_without_password(account_params)
    end
  end

  def after_update_path_for(resource)
    edit_user_registration_path
  end

  def edit
    if current_user.nil?
      redirect_to root_path
    else
      super
    end
  end
end
