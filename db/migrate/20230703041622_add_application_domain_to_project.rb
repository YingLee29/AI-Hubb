class AddApplicationDomainToProject < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :application_domain, :string
  end
end
