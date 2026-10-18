class CreateAiApiInputFields < ActiveRecord::Migration[7.0]
  def change
    create_table :ai_a_pi_input_fields do |t|
      t.string :public_uid, null: false
      t.string :name, null: false
      t.string :type, null: false
      t.string :default_value, null: false
      t.integer :ai_api_id, null: false

      t.timestamps
    end
  end
end
