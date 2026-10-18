class CreatePromptInputFields < ActiveRecord::Migration[7.0]
  def change
    create_table :prompt_input_fields do |t|
      t.string :public_uid, null: false
      t.string :name, null: false
      t.string :value, null: false
      t.integer :prompt_id, null: false

      t.timestamps
    end
  end
end
