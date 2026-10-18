class CreateCompanies < ActiveRecord::Migration[7.0]
  def change
    create_table :companies do |t|
      t.string :public_uid, null: false
      t.string :name, null: false
      t.string :address
      t.integer :company_type, null: false, default: 0
      t.string :v_company_uid, null: false

      t.timestamps
    end

    add_index :companies, :name, unique: true
    add_index :companies, :v_company_uid, unique: true
  end
end
