class RemoveRequiredForPromptModel < ActiveRecord::Migration[7.0]
  def change
    change_column_null :prompts, :model, true
  end
end
