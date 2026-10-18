class RemoveIndexNameCompanies < ActiveRecord::Migration[7.0]
  def change
    remove_index :companies, column: :name, unique: true
  end
end
