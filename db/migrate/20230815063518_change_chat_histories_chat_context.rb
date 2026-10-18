class ChangeChatHistoriesChatContext < ActiveRecord::Migration[7.0]
  def up
    change_column :chat_histories, :chat_context, :text
  end

  def down
    change_column :chat_histories, :chat_context, :string
  end

end
