class UsersCallbackController < ApplicationController
  skip_before_action :authenticate_user!
  layout 'authenticate_Local'
  def callback
    return if params[:code].nil?
    url = "#{ENV['Local_ID_BASE_URL']}/api/v1/oauth2/me"
    response = HTTParty.get(url, body: { code: params[:code] }.to_json, headers: { 'Content-Type': 'application/json'})
    redirect_to callback_complete_path(code: params[:code], user_data: response)
  end

  def login_complete
    url = "#{ENV['Local_ID_BASE_URL']}/api/v1/oauth2/auth"
    @user_data = JSON.parse(params[:user_data]) if params[:user_data].present?
    raise ActiveRecord::RecordNotFound unless @user_data.present?

    response = HTTParty.post(url, body: { code: params[:code] }.to_json,
      headers: { 'Content-Type': 'application/json', 'X-User-Id': @user_data.dig('users', 'uid')})

    id_token = response['id_token']
    if id_token.present? && response.code == 200
      company = Company.find_by(v_company_uid: @user_data.dig('users', 'company_uid'))
      if company.blank?
        company = Company.create!(
          name: @user_data.dig('users', 'company_name'),
          address: @user_data.dig('users', 'company_address'),
          company_type: @user_data.dig('users', 'company_type'),
          v_company_uid: @user_data.dig('users', 'company_uid')
        )
      end
      user_email = @user_data.dig('users', 'email')
      user_name = @user_data.dig('users', 'name')
      user_role = @user_data.dig('users', 'role')
      user_phone =  @user_data.dig('users', 'phone')
      user_gender = @user_data.dig('users', 'gender')
      user = User.find_by(email: user_email)

      if user.blank?
        user = User.create(
          email: user_email,
          password: 'Aa@123456',
          name: user_name,
          role: user_role == 'admin' ? :admin : :member,
          company_id: company.id,
          phone: user_phone,
          gender: user_gender
        )
      end

      if @user_data.dig('users', 'is_representative')
        current_representative_user = company.users.find_by(is_representative: true)
        if current_representative_user.present?
          if current_representative_user != user
            current_representative_user.update!(is_representative: false)
            user.update!(is_representative: true, role: :admin)
          end
        else
          user.update!(is_representative: true, role: :admin)
        end
      end

      sign_in user unless user_signed_in?
      handle_authenticate_success
    else
      handle_authenticate_failure
    end
    session['id_token'] = id_token
    session['x_user_id'] = @user_data&.dig('users', 'uid')
    respond_to do |format|
      format.html
    end
  end

  private
    def handle_authenticate_failure
      @response = {root_path:, message: 'Authentication failed'}
      flash.now[:danger] = 'Authenticate failed'
      return
    end

    def handle_authenticate_success
      @response = {root_path:, message: 'Authentication successful'}
    end
end
