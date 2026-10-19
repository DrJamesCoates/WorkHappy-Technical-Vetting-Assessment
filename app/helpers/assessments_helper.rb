module AssessmentsHelper
  # Average of the numeric answers, rounded. Misbehaves on string answers,
  # nils and empty responses.
  def assessment_score(assessment)
    answers = assessment.responses_json.select { |k, _| k.start_with?("q") }.values
    (answers.sum { |v| v.to_i } / answers.size.to_f).round(1)
  rescue StandardError
    nil
  end

  def status_badge(status)
    case status
    when "completed", "complete" then "green"
    when "pending" then "orange"
    when "in_progress" then "blue"
    end
  end
end
