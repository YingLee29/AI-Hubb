class AddDescriptionToPrompts < ActiveRecord::Migration[7.0]
  def change
    add_column :prompts, :description, :string
  end
end
