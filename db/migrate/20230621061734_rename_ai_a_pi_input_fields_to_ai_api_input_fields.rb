class RenameAiAPiInputFieldsToAiApiInputFields < ActiveRecord::Migration[7.0]
  def change
    rename_table :ai_a_pi_input_fields, :ai_api_input_fields
  end
end
