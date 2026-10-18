class CreateAiApis < ActiveRecord::Migration[7.0]
  def change
    create_table :ai_apis do |t|
      t.string :public_uid, null: false
      t.string :name, null: false
      t.string :model_list, array: true, default: []
      t.string :parameter_list, array: true, default: []
      t.text :message_template

      t.timestamps
    end
  end
end
