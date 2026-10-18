class CreateLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :logs do |t|
      t.string :ip
      t.string :user_agent
      t.string :api_endpoint
      t.text :api_body
      t.string :ai_endpoint
      t.text :ai_body
      t.text :response
      t.timestamps
    end
  end
end
