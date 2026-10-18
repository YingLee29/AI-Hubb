class AddCompanyIdToProjects < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :company_id, :integer
  end
end
