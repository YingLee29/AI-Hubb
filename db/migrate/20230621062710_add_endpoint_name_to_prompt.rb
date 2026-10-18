class AddEndpointNameToPrompt < ActiveRecord::Migration[7.0]
  def change
    add_column :prompts, :endpoint_name, :string
  end
end
