class AddPromptIdToChatHistories < ActiveRecord::Migration[7.0]
  def change
    add_column :chat_histories, :prompt_id, :integer
  end
end
