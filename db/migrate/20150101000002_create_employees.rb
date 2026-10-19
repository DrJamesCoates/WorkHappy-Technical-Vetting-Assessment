class CreateEmployees < ActiveRecord::Migration[7.2]
  def change
    create_table :employees do |t|
      t.references :company, foreign_key: true
      t.string :name
      t.string :email
      t.timestamps
    end
  end
end
