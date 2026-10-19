# Legacy-flavoured seed data: ~200k assessments with messy statuses and answers.
srand(42)
COMPANIES = 10
EMPLOYEES_PER_COMPANY = 200
ASSESSMENTS = 200_000

[Assessment, Employee, AdminUser, Company].each(&:delete_all)

COMPANIES.times do |i|
  c = Company.create!(name: "Company #{i + 1}")
  AdminUser.create!(company: c, email: "admin#{i + 1}@example.com", password: "password")
  Employee.insert_all(Array.new(EMPLOYEES_PER_COMPANY) { |j|
    { company_id: c.id, name: "Employee #{i + 1}-#{j + 1}", email: "emp#{i + 1}-#{j + 1}@example.com",
      created_at: Time.current, updated_at: Time.current }
  })
end

STATUSES = (
  ["completed"] * 14 + ["complete"] * 8 + ["Complete"] * 5 + ["comp"] * 6 + ["done"] * 6 + ["DONE "] * 1 +
  ["pending"] * 8 + ["in_progress"] * 7 + [nil] * 10 + [""] * 5 + ["n/a"] * 5 +
  ["needs_follow_up"] * 5 + ["archived"] * 5 + [" pending", "In Progress", "needs follow up"] * 2
).freeze
NOTES = ["Lower back pain after long meetings", "Wrist numbness at night", "No issues", "Neck strain, sees physio on Mondays"].freeze

def responses
  r = rand
  return {} if r < 0.02
  h = (1..10).to_h do |q|
    v = rand(1..5)
    v = v.to_s if rand < 0.10
    v = nil if rand < 0.05
    ["q#{q}", v]
  end
  h["notes"] = NOTES.sample
  h["pain_description"] = NOTES.sample
  h
end

employees = Employee.pluck(:id, :company_id, :email)
now = Time.current
employees_by_company = employees.group_by { |_, c, _| c }

ASSESSMENTS.times.each_slice(5_000) do |batch|
  rows = batch.map {
    id, company_id, email = employees.sample
    { company_id: company_id, employee_id: id, employee_email: email, status: STATUSES.sample,
      responses_json: responses, created_at: now - rand(0..730).days - rand(86_400).seconds }
  }
  Assessment.insert_all(rows)
end
puts "Seeded #{Company.count} companies, #{Employee.count} employees, #{Assessment.count} assessments"
