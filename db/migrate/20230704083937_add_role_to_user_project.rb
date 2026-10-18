class AddRoleToUserProject < ActiveRecord::Migration[7.0]
  def change
    add_column :user_projects, :role, :integer, default: 2
  end
end
