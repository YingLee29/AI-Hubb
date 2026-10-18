module ProjectHelper
  def current_project
    Project.find_by!(public_uid: params[:project_id]) if params[:project_id].present?
  end

  def is_selected_user(user, user_projects)
    return user_projects&.include?(user)
  end

  def user_project_member(project)
    return if current_user.nil? || current_user.admin?

    user_project = project.user_projects.find_by(user_id: current_user.id)
    user_project&.project_member?
  end
end
