class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :check_permission_admin
  before_action :user, only: [:edit, :update, :destroy, :render_edit]
  before_action :check_current_user_or_representative, only: [:edit, :update, :destroy]
  before_action :project_manager_ids, only: [:update]
  before_action :project_member_ids, only: [:update]
  def index
    @keyword = params[:keyword]
    @search = current_tenant.users.ransack(name_i_cont: @keyword)
    @users = current_tenant.users.ransack(name_i_cont: @keyword)
    .result
    .order(Arel.sql("CASE WHEN id = #{current_user.id} THEN 0 ELSE 1 END, created_at DESC"))
    .page(params[:page])
    .per(10)
  end

  def update
    project_member_ids = find_project_ids(params[:project_member])
    ActiveRecord::Base.transaction do
      if user.update!(user_params.except(:project_manager, :project_member))
        user.user_projects.destroy_all

        user.user_projects.create!(project_manager_ids.map { |project_id| { user_id: user.id, project_id: project_id, role: :project_manager } })
        user.user_projects.create!(project_member_ids.map { |project_id| { user_id: user.id, project_id: project_id, role: :project_member} })

        respond_to do |format|
          format.json { render :json => { message: I18n.t('views.message.update_successfully'), errors: [] } }
        end
      end
    end
  rescue => exception
    respond_to do |format|
      format.json { render :json => {
        errors: user.errors.to_hash
      } }
    end
  end

  def destroy
    user.destroy
    reset_session if user.id == current_user&.id
    respond_to do |format|
      format.json { render :json => {
        redirect_url: users_path,
        message: I18n.t('views.message.delete_successfully')
      } }
    end
  end

  def render_edit
    @projects = current_tenant.projects.all
    @user_projects_manager = user.user_projects.project_manager_project_ids
    @user_projects_member = user.user_projects.project_member_project_ids
    @user = user
  end

  def render_create
    @projects = current_tenant.projects.all
  end

  private

  def set_reset_password_token user
    raw, enc = Devise.token_generator.generate(User, :reset_password_token)

    user.reset_password_token   = enc
    user.reset_password_sent_at = Time.now.utc
    user.update!(reset_password_token: enc, reset_password_sent_at: Time.zone.now)
    raw
  end

  def send_reset_password_instructions user, password
    token = set_reset_password_token user
    MemberMailer.reset_password_member(user, password, token).deliver
  end

  def user
    @user ||= current_tenant.users.find_by!(public_uid: params[:id])
  rescue ActiveRecord::RecordNotFound => e
    render json: {
      error: I18n.t('views.message.data_not_found')
    }, status: 404
  end

  def check_current_user_or_representative
    if user.id == current_user.id || user.is_representative?
      redirect_to root_path, flash: { danger: 'Cannot update, delete yourself or representative' }
    end
  end

  def check_current_user
    if user.id == current_user.id
      redirect_to root_path, flash: { danger: I18n.t('views.message.update_self') }
    end
  end

  def project_manager_ids
    @project_manager_ids ||= find_project_ids(params[:project_manager])
  end

  def project_member_ids
    @project_member_ids ||= find_project_ids(params[:project_member])
  end


  def find_project_ids(project_uids)
    project_ids = []

    project_uids&.each do |uid|
      project = current_tenant.projects.find_by(public_uid: uid)

      unless project
        render json: { error: I18n.t('views.message.data_not_found') }, status: 404
        return
      end

      project_ids << project.id
    end

    project_ids
  end

  def user_params
    params.permit(:role, :project_manager, :project_member)
  end
end
