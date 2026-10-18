class AddIsRepresentativeToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :is_representative, :boolean, default: false
  end
end
