class ChangeAssociation < ActiveRecord::Migration[7.0]
  def change
    add_column :prompts, :project_id, :integer
  end
end
