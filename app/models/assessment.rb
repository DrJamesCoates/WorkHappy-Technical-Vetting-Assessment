class Assessment < ApplicationRecord
  VALID_STATUSES = %w[pending in_progress completed needs_follow_up archived].freeze

  belongs_to :company
  belongs_to :employee

  validates :status, inclusion: { in: VALID_STATUSES }
end
