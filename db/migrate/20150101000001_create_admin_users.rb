class CreateAdminUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :admin_users do |t|
      t.references :company, foreign_key: true
      t.string :email
      t.string :password_digest
      t.timestamps
    end
  end
end
