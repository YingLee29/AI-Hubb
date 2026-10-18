class CreateProjects < ActiveRecord::Migration[7.0]
  def change
    create_table :projects do |t|
      t.string :public_uid, null: false
      t.string :name, null: false
      t.string :description

      t.timestamps
    end
  end
end
