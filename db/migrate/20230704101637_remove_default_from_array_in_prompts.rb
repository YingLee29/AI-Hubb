class RemoveDefaultFromArrayInPrompts < ActiveRecord::Migration[7.0]
  def change
    change_column :prompts, :parameter_list, :string, default: nil, array: false
    change_column :prompts, :messages_params, :string, default: nil, array: false
    change_column :prompts, :functions_params, :string, default: nil, array: false
  end
end
