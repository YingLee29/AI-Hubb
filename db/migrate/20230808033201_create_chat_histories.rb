class CreateChatHistories < ActiveRecord::Migration[7.0]
  def change
    create_table :chat_histories do |t|
      t.string :public_uid, null: false
      t.string :chat_name, default: "New chat"
      t.integer :user_id, null: false
      t.string  :chat_context, default: ""
      t.integer :default_models, default: 0
      t.json :metadata, default: []

      t.timestamps
    end
  end
end
