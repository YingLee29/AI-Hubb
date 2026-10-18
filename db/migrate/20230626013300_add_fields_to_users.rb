class AddFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :phone, :string
    add_column :users, :role, :integer, default: 2
    add_column :users, :gender, :integer
  end
end
