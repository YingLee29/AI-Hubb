class UserMailer < ApplicationMailer

  def reset_password_instructions(user)
    @user = user
    mail(to: @user.email, subject: "Local ID Reset password")
  end
end
