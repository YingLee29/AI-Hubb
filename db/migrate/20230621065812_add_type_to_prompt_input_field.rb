class AddTypeToPromptInputField < ActiveRecord::Migration[7.0]
  def change
    add_column :prompt_input_fields, :type, :string
  end
end
