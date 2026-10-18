class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :current_project, :check_accessable, only: %i[show update destroy]
  before_action :list_projects, only: %i[index]
  before_action :check_permission_admin, only: %i[create]
  def index
    @keyword = params[:keyword]&.strip
    @search = @list_projects.ransack(name_i_cont: @keyword)
    @projects = @search.result.order(created_at: :desc).page(params[:page]).per(10)
    @user_list = current_tenant.users
    @project_manager = current_tenant.users
    @project_member = current_tenant.users

    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    @api_domain = ENV['DOMAIN_API']
    @project = Project.new(project_params.merge(company_id: current_tenant.id))
    @user_list = current_tenant.users.reject { |u| u == current_user }
    ActiveRecord::Base.transaction do
      if @project.save!
        params[:users_manager]&.map do |user_uid|
          user_data = current_tenant.users.find_by(public_uid: user_uid)
          unless user_data
            @recordnotfound = I18n.t('activerecord.recordnotfound')
            raise ActiveRecord::RecordNotFound
          end
          @project.user_projects.create!(user: user_data, role: 1)
        end
        params[:users_member]&.map do |user_uid|
          user_data = current_tenant.users.find_by(public_uid: user_uid)
          unless user_data
            @recordnotfound = I18n.t('activerecord.recordnotfound')
            raise ActiveRecord::RecordNotFound
          end
          @project.user_projects.create!(user: user_data)
        end
      end
    end
  rescue => exception
    respond_to do |format|
      format.json { render :json => {
        errors: @project.errors.to_hash
      } }
    end
  end

  def render_edit
    @user_list = current_tenant.users.reject { |u| u == current_user }
    @current_project = current_tenant.projects.find_by!(public_uid: params[:id])
    @user_projects_manager = @current_project&.user_projects.where(role: 1)&.map(&:user_id)
    @user_projects_member = @current_project&.user_projects.where(role: 2)&.map(&:user_id)
    @project_manager = current_tenant.users.where.not(id: @user_projects_member)
    @project_member = current_tenant.users.where.not(id:  @user_projects_manager)
  end

  def render_create
    @user_list = current_tenant.users
    @project_manager = current_tenant.users
    @project_member = current_tenant.users
  end

  def render_user_project_role_create
    @user_list = current_tenant.users
    @project_manager = if params[:member].present?
                        current_tenant.users.where.not(public_uid: params[:member])
                      else
                        current_tenant.users
                      end
    @project_member = if params[:manager].present?
                        current_tenant.users.where.not(public_uid: params[:manager])
                      else
                        current_tenant.users
                      end
    @manager_selecte = params[:manager]
    @member_selecte =  params[:member]
  end

  def render_user_project_role_edit
    @user_list = User.all
    @current_project = current_tenant.projects.find_by!(public_uid: params[:id])
    @user_projects_manager = @current_project&.user_projects.where(role: 1)&.map(&:user_id)
    @user_projects_member = @current_project&.user_projects.where(role: 2)&.map(&:user_id)
    @project_manager = if params[:member].present?
                        current_tenant.users.where.not(public_uid: params[:member])
                      else
                        current_tenant.users
                      end
    @project_member = if params[:manager].present?
                        current_tenant.users.where.not(public_uid: params[:manager])
                      else
                        current_tenant.users
                      end
    @user_projects_manager = current_tenant.users.where(public_uid: params[:manager])&.map(&:id)
    @user_projects_member = current_tenant.users.where(public_uid: params[:member])&.map(&:id)
    @manager_selecte = params[:manager]
    @member_selecte =  params[:member]
  end

  def update
    @api_domain = ENV['DOMAIN_API']
    @user_list = current_tenant.users.reject { |u| u == current_user }
    @project = current_tenant.projects.find_by!(public_uid: params[:id])
    raise ActiveRecord::RecordNotFound unless @project.present?
    ActiveRecord::Base.transaction do
      if @project.update!(project_params)
        @project.user_projects.destroy_all
        params[:users_manager]&.map do |user_uid|
          user_data = current_tenant.users.find_by(public_uid: user_uid)
          unless user_data
            @recordnotfound = I18n.t('activerecord.recordnotfound')
            raise ActiveRecord::RecordNotFound
          end
          @project.user_projects.create!(user: user_data, role: 1)
        end
        params[:users_member]&.map do |user_uid|
          user_data = current_tenant.users.find_by(public_uid: user_uid)
          unless user_data
            @recordnotfound = I18n.t('activerecord.recordnotfound')
            raise ActiveRecord::RecordNotFound
          end
          @project.user_projects.create!(user: user_data)
        end
      end
    end
  rescue => exception
    respond_to do |format|
      format.json { render :json => {
        errors: @project.errors.to_hash
      } }
    end
  end

  def destroy
    @project.destroy!
    @success = true
    @message = I18n.t('views.prompt.modal.detele_successfully')
  end

  private

  def project_params
    params.permit(:name, :description, :application_domain, :ip_white_list)
  end

  def current_project
    @project = current_tenant.projects.find_by!(public_uid: params[:id])
  end

  def list_projects
    @list_projects = current_user.admin? ? current_tenant.projects : current_user.projects
  end

  def check_accessable
    return if current_user.admin?
    project_role = current_user.user_projects.find_by(project_id: @project&.id)&.role
    raise ActiveRecord::RecordNotFound unless project_role == 'project_manager'
  end
end
