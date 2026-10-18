# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController
  layout "layouts/login_layout"
  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      flash[:alert] = "You will receive an email with instructions on how to reset your password in a few minutes."
      respond_with({}, location: after_sending_reset_password_instructions_path_for(resource_name))
    else
      respond_with(resource)
    end
  end

  def edit
    self.resource = resource_class.new
    resource.reset_password_token = params[:reset_password_token]
    user = User.with_reset_password_token(resource.reset_password_token)
    return redirect_to '/404' unless user.present? && user.reset_password_period_valid?
    set_minimum_password_length
  end
end
