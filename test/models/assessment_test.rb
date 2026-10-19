require "test_helper"

class AssessmentTest < ActiveSupport::TestCase
  setup do
    company = Company.create!(name: "Acme")
    @employee = Employee.create!(company: company, name: "Ann", email: "ann@acme.test")
    @assessment = Assessment.create!(company: company, employee: @employee, status: "pending", created_at: Time.current)
  end

  test "accepts every valid status" do
    Assessment::VALID_STATUSES.each do |status|
      @assessment.status = status

      assert @assessment.valid?, "expected #{status.inspect} to be valid"
    end
  end

  test "rejects invalid statuses on create" do
    [nil, "", "n/a", "comp", "done", "complete", "Completed", " pending", "in progress"].each do |status|
      assessment = Assessment.new(company: @employee.company, employee: @employee, status: status)

      assert_not assessment.valid?, "expected #{status.inspect} to be invalid"
      assert assessment.errors.of_kind?(:status, :inclusion)
    end
  end

  test "rejects updating an existing assessment to an invalid status" do
    assert_not @assessment.update(status: "done")
    assert_equal "pending", @assessment.reload.status
  end

  test "rejects saving a legacy record that still has an invalid status" do
    @assessment.update_column(:status, "comp")

    assert_not @assessment.update(employee_email: "new@acme.test")
  end
end
