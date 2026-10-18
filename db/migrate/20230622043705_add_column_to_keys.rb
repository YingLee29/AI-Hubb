class AddColumnToKeys < ActiveRecord::Migration[7.0]
  def change
    add_column :keys, :user_id, :integer
    add_column :keys, :used, :boolean, default: false
    change_column_null :keys, :valid_until, true
  end
end
