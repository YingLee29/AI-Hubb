class AddPromptIdToLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :logs, :prompt_id, :integer
  end
end
