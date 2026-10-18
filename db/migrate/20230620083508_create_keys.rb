class CreateKeys < ActiveRecord::Migration[7.0]
  def change
    create_table :keys do |t|
      t.string :public_uid, null: false
      t.string :key_string, null: false
      t.string :note
      t.datetime :valid_until, null: false
      t.integer :prompt_id, null: false

      t.timestamps
    end
  end
end
