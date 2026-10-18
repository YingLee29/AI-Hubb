class AddOptionsToAiApiInputFields < ActiveRecord::Migration[7.0]
  def change
    add_column :ai_api_input_fields, :options, :string, array: true, default: []
  end
end
