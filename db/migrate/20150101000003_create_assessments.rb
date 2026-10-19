class CreateAssessments < ActiveRecord::Migration[7.2]
  def change
    create_table :assessments do |t|
      t.integer :company_id
      t.integer :employee_id
      t.string :employee_email
      t.string :status
      t.jsonb :responses_json
      t.datetime :created_at
    end
    add_index :assessments, :company_id
  end
end
