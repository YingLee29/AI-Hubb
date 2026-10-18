class ChangeDataTypeOfPrompt < ActiveRecord::Migration[7.0]
  def change
    change_column :prompt_input_fields, :value, :text
  end
end
