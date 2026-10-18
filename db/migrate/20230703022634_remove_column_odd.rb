class RemoveColumnOdd < ActiveRecord::Migration[7.0]
  def change
    remove_column :prompts, :endpoint_url
    remove_column :prompts, :message_template
    remove_column :ai_apis, :message_template
  end
end
