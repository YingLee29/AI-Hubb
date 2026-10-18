class RemoveApplicationDomainFromPrompt < ActiveRecord::Migration[7.0]
  def up
    remove_column :prompts, :application_domain
  end

  def down
    add_column :prompts, :application_domain, :string
  end
end
