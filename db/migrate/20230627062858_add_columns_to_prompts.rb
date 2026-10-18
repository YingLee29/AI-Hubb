class AddColumnsToPrompts < ActiveRecord::Migration[7.0]
  def change
    add_column :prompts, :messages_params, :string, array: true, default: []
    add_column :prompts, :functions_params, :string, array: true, default: []
  end
end
