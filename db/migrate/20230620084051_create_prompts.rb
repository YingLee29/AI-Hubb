class CreatePrompts < ActiveRecord::Migration[7.0]
  def change
    create_table :prompts do |t|
      t.string :public_uid, null: false
      t.string :name, null: false
      t.integer :ai_api_id, null: false
      t.string :model, null: false
      t.string :application_domain, null: false
      t.string :endpoint_url, null: false
      t.string :parameter_list, array: true, default: []
      t.text :message_template

      t.timestamps
    end
  end
end
