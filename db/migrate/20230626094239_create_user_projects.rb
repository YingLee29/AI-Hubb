class CreateUserProjects < ActiveRecord::Migration[7.0]
  def change
    create_table :user_projects do |t|
      t.string :public_uid, null: false
      t.integer :user_id, null: false
      t.integer :project_id, null: false

      t.timestamps
    end
  end
end
