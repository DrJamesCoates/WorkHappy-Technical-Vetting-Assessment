require "test_helper"
require "csv"

class AssessmentsExportTest < ActionDispatch::IntegrationTest
  setup do
    @company = Company.create!(name: "Acme")
    @other_company = Company.create!(name: "Globex")
    @admin = AdminUser.create!(company: @company, email: "admin@acme.test", password: "secret")
    @employee = Employee.create!(company: @company, name: "Ann", email: "ann@acme.test")
    @other_employee = Employee.create!(company: @other_company, name: "Bob", email: "bob@globex.test")
  end

  test "requires a logged in admin" do
    get export_assessments_path(format: :csv)

    assert_redirected_to login_path
  end

  test "exports only the logged in admin's company, ignoring any company_id param" do
    mine = create_assessment
    theirs = create_assessment(company: @other_company, employee: @other_employee)
    login

    get export_assessments_path(format: :csv, company_id: @other_company.id)

    assert_response :success
    assert_equal [mine.id.to_s], exported_ids
    refute_includes exported_ids, theirs.id.to_s
  end

  test "date range is inclusive of both days" do
    before = create_assessment(created_at: "2025-02-28 23:59:59")
    first = create_assessment(created_at: "2025-03-01 00:00:00")
    last = create_assessment(created_at: "2025-03-03 23:59:59")
    after = create_assessment(created_at: "2025-03-04 00:00:00")
    login

    get export_assessments_path(format: :csv, from: "2025-03-01", to: "2025-03-03")

    assert_equal [first.id, last.id].map(&:to_s).sort, exported_ids.sort
    assert_empty [before.id, after.id].map(&:to_s) & exported_ids
  end

  test "same day range returns only that day" do
    on_day = create_assessment(created_at: "2025-03-01 12:00:00")
    create_assessment(created_at: "2025-03-02 12:00:00")
    login

    get export_assessments_path(format: :csv, from: "2025-03-01", to: "2025-03-01")

    assert_equal [on_day.id.to_s], exported_ids
  end

  test "filters by status" do
    pending = create_assessment(status: "pending")
    create_assessment(status: "archived")
    login

    get export_assessments_path(format: :csv, status: "pending")

    assert_equal [pending.id.to_s], exported_ids
  end

  test "redacts free text answers and personal identifiers" do
    create_assessment(responses_json: { "q1" => 3, "notes" => "bad back", "pain_description" => "wrist" })
    login

    get export_assessments_path(format: :csv)

    assert_equal %w[id created_at status responses_json], CSV.parse(response.body, headers: true).headers
    assert_includes response.body, "q1"
    refute_includes response.body, "bad back"
    refute_includes response.body, "wrist"
    refute_includes response.body, "ann@acme.test"
  end

  test "handles assessments with no responses" do
    create_assessment(responses_json: nil)
    login

    get export_assessments_path(format: :csv)

    assert_response :success
    assert_equal 1, exported_ids.size
  end

  test "rejects an invalid status" do
    login

    get export_assessments_path(format: :csv, status: "bogus")

    assert_response :unprocessable_entity
    assert_match(/Status must be one of/, errors.first)
  end

  test "rejects an unparseable date" do
    login

    get export_assessments_path(format: :csv, from: "nope")

    assert_response :unprocessable_entity
    assert_equal ["From date is not a valid date"], errors
  end

  test "rejects a reversed date range" do
    login

    get export_assessments_path(format: :csv, from: "2025-03-02", to: "2025-03-01")

    assert_response :unprocessable_entity
    assert_equal ["From date must be on or before To date"], errors
  end

  test "reports every validation error at once" do
    login

    get export_assessments_path(format: :csv, status: "bogus", from: "2025-03-02", to: "2025-03-01")

    assert_response :unprocessable_entity
    assert_equal 2, errors.size
  end

  private

  def login
    post login_path, params: { email: @admin.email, password: "secret" }
  end

  def create_assessment(company: @company, employee: @employee, **attrs)
    Assessment.create!({
      company: company, employee: employee, employee_email: employee.email,
      status: "pending", responses_json: { "q1" => 3 }, created_at: "2025-03-01 12:00:00"
    }.merge(attrs))
  end

  def exported_ids
    CSV.parse(response.body, headers: true).map { |row| row["id"] }
  end

  def errors
    JSON.parse(response.body)["errors"]
  end
end
