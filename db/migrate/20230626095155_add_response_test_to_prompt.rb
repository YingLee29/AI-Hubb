class AddResponseTestToPrompt < ActiveRecord::Migration[7.0]
  def change
    add_column :prompts, :prompt_test_response, :json
  end
end
