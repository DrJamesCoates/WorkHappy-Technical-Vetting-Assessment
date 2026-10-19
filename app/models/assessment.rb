class Assessment < ApplicationRecord
  VALID_STATUSES = %i[pending in_progress completed needs_follow_up archived]

  belongs_to :company
  belongs_to :employee

  # Returns responses_json excluding free-text answers
  def redacted_responses_json
    responses_json
      &.slice("q1", "q2", "q3", "q4", "q5", "q6", "q7", "q8", "q9", "q10")
      &.to_json
  end
end
