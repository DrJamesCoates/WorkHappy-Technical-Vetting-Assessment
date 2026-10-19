namespace :assessments do
  # Maps normalized legacy statuses (strip, downcase, spaces to underscores) to valid ones.
  LEGACY_STATUS_MAP = {
    "completed" => "completed", "complete" => "completed", "comp" => "completed", "done" => "completed",
    "pending" => "pending", "in_progress" => "in_progress",
    "needs_follow_up" => "needs_follow_up", "archived" => "archived",
    "" => "pending", "n/a" => "pending" # nil is normalized to ""
  }.freeze

  desc "Normalize legacy assessment statuses to the valid set. Dry run by default. " \
       "Usage: rake assessments:normalize_legacy_statuses[company_id,dry_run] (dry_run=false to write)"
  task :normalize_legacy_statuses, [ :company_id, :dry_run ] => :environment do |_, args|
    dry_run = args[:dry_run] != "false"
    scope = args[:company_id].present? ? Assessment.where(company_id: args[:company_id]) : Assessment.all
    normalize = ->(raw) { raw.to_s.strip.downcase.tr(" ", "_") }

    counts = scope.group(:status).count
    unmapped = counts.keys.reject { |raw| LEGACY_STATUS_MAP.key?(normalize.(raw)) }
    abort "Aborting, no mapping for: #{unmapped.inspect}" if unmapped.any?

    changes = counts.reject { |raw, _| raw == LEGACY_STATUS_MAP[normalize.(raw)] }
    changes.each { |raw, n| puts "#{raw.inspect} -> #{LEGACY_STATUS_MAP[normalize.(raw)]}: #{n}" }
    puts "#{changes.values.sum} rows to update (#{dry_run ? 'dry run, nothing written' : 'writing'})"

    next if dry_run

    updated = 0
    changes.each_key do |raw|
      scope.where(status: raw).in_batches(of: 5_000) do |batch|
        # update_all skips validations on purpose: legacy rows are invalid by definition.
        updated += batch.update_all([
          "legacy_status = status, status_backfilled_at = ?, status = ?",
          Time.current, LEGACY_STATUS_MAP[normalize.(raw)]
        ])
        puts "updated #{updated}"
        sleep ENV.fetch("BATCH_SLEEP", "0.2").to_f
      end
    end
  end

  desc "Restore the original statuses saved in legacy_status. Usage: rake assessments:restore_legacy_statuses[company_id]"
  task :restore_legacy_statuses, [ :company_id ] => :environment do |_, args|
    scope = args[:company_id].present? ? Assessment.where(company_id: args[:company_id]) : Assessment.all

    reverted = 0
    scope.where.not(status_backfilled_at: nil).in_batches(of: 5_000) do |batch|
      reverted += batch.update_all("status = legacy_status, legacy_status = NULL, status_backfilled_at = NULL")
      puts "reverted #{reverted}"
      sleep ENV.fetch("BATCH_SLEEP", "0.2").to_f
    end
  end
end
