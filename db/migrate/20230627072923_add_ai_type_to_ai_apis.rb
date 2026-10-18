class AddAiTypeToAiApis < ActiveRecord::Migration[7.0]
  def change
    add_column :ai_apis, :ai_type, :integer, default: 0
  end
end
