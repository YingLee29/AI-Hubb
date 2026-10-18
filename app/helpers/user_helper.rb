module UserHelper
  def is_selected_project_manager(project, user_projects_manager)
    return user_projects_manager&.include?(project)
  end

  def is_selected_project_member(project, user_projects_member)
    return user_projects_member&.include?(project)
  end
end
