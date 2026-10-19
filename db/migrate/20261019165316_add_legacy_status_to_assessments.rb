class AddLegacyStatusToAssessments < ActiveRecord::Migration[7.2]
  # Nullable columns without defaults are metadata-only in PostgreSQL, so this is safe on a large live table.
  def change
    add_column :assessments, :legacy_status, :string
    add_column :assessments, :status_backfilled_at, :datetime
  end
end
