class Assessment < ApplicationRecord
  SCORE_KEYS = (1..10).map { |i| "q#{i}" }.freeze

  belongs_to :company
  belongs_to :employee

  # Returns the average of the scores for q1 - q10, rounded to one decimal place.
  # Nils and invalid values are treated as blank and excluded from the average:
  # numbers less than zero, and strings that are not numbers of zero or more.
  # Returns nil when every value is blank or invalid.
  def average_assessment_score
    scores = SCORE_KEYS.filter_map { |key| valid_score(responses_json&.dig(key)) }
    return if scores.empty?

    (scores.sum / scores.size).round(1)
  end

  private

  def valid_score(value)
    case value
    when Numeric
      value.to_f if value >= 0
    when String
      number = Float(value, exception: false)
      number if number && number >= 0
    end
  end
end
