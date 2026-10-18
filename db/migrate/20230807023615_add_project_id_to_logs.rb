class AddProjectIdToLogs < ActiveRecord::Migration[7.0]
  def up
    add_column :logs, :project_id, :integer
    Prompt.all.each do |prompt|
      Log.where(prompt_id: prompt.id).update_all(project_id: prompt.project_id)
    end
  end

  def down
    remove_column :logs, :project_id
  end
end
