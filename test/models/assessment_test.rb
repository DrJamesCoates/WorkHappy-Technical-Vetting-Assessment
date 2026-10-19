require "test_helper"

class AssessmentTest < ActiveSupport::TestCase
  def score(responses)
    Assessment.new(responses_json: responses).average_assessment_score
  end

  test "averages q1 - q10 and rounds to one decimal" do
    assert_equal 3.7, score("q1" => 4, "q2" => 4, "q3" => 3)
  end

  test "accepts floats and numeric strings" do
    assert_equal 3.5, score("q1" => "4", "q2" => 3.0)
    assert_equal 2.5, score("q1" => 2.5)
  end

  test "excludes nils instead of counting them as zero" do
    assert_equal 4.0, score("q1" => 4, "q2" => nil)
  end

  test "excludes negative numbers and strings that are not positive numbers" do
    assert_equal 4.0, score("q1" => 4, "q2" => -1, "q3" => "abc", "q4" => "-2", "q5" => "")
  end

  test "treats zero as valid for numbers and strings" do
    assert_equal 1.5, score("q1" => 4, "q2" => 0, "q3" => "0", "q4" => "2", "q5" => nil)
  end

  test "ignores keys other than q1 - q10" do
    assert_equal 4.0, score("q1" => 4, "q11" => 1, "notes" => "5")
  end

  test "is nil when every value is blank or invalid" do
    assert_nil score({})
    assert_nil score(nil)
    assert_nil score("q1" => nil, "q2" => "abc", "q3" => -3)
  end
end
