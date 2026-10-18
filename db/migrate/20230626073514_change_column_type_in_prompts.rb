class ChangeColumnTypeInPrompts < ActiveRecord::Migration[7.0]
  def change
    change_column :prompts, :description, :text
  end
end
