crumb :root do
  link t("home"), root_path
end

crumb :users do
  link t("views.user.user_management"), users_path
end
crumb :logs do
  link t("views.log.log_management"), logs_path
end

crumb :projects do
  link t("views.project.pm"), projects_path
end

crumb :user do
  link t("views.personal_settings.personal_setting"),  edit_user_registration_path
end

crumb :prompts do
  link t("views.prompt.prompt_management"), project_prompts_path
  parent :projects
end

crumb :prompt do |prompt|
  if action_name == "new"
    link t("views.prompt.create_prompt"), new_project_prompt_path(prompt.project)
  else
    link t("views.prompt.prompt_ai_setting"), project_prompt_path(prompt.project, prompt)
  end
  parent :prompts
end

crumb :playground do
  link t("views.playground.playground"), current_user_playground_path
end

# crumb :project_issues do |project|
#   link "Issues", project_issues_path(project)
#   parent :project, project
# end

# crumb :issue do |issue|
#   link issue.title, issue_path(issue)
#   parent :project_issues, issue.project
# end

# If you want to split your breadcrumbs configuration over multiple files, you
# can create a folder named `config/breadcrumbs` and put your configuration
# files there. All *.rb files (e.g. `frontend.rb` or `products.rb`) in that
# folder are loaded and reloaded automatically when you change them, just like
# this file (`config/breadcrumbs.rb`).
