# Task 3 Solution
## Standardize and validate against set of statuses
For this, I had Claude add an explictly valid set of assessment statuses to the assessment model. This set is validated against when creating or updating an assessment, so any new or existing assessment that is created or updated with an invalid assessment status would be set to invalid and the change would not be saved until a valid status was selected. Unfortunately, I had not implemented a way to create or edit an assessment object from the UI so to test this functionality is not possible.

## Implement back fill of valid statuses to assessments
The solution to this problem involved a back-and-forth conversation with Claude on the best way to go about this. The important elements that needed to be considered were: determining what the existing status values are, and what valid values those should be mapped to, options for safely implementing these changes, and a rollback strategy. We eventually decided that the existing values should be normalized first (strip, downcase, spaces to underscores) and then map those from a fixed table in code:
```
completed, complete, comp, done => completed
pending, in_progress, needs_follow_up, archived => remain as they are
nil, "", n/a => pending
```
Mapping nil, "", and n/a would be discussed with the product and engineering teams first, but I would argue that a pending status is the least harmful status that could be implied from those invalid values.

We created a skeleton of a task which has the option for a dry run and would be run by an engineer after hours.

### Discovering existing values
Before I would be able to define the mapping, I would have to list the distinct values present. If the table has millions of rows, I would run this against a follower or fork database and not the primary database.

The seeded data has 16 distinct values (for example `completed`, `complete`, `Complete`, `comp`, `done`, `"DONE "`, `" pending"`, `"In Progress"`, `"needs follow up"`, `nil`, `""` and `"n/a"`). The task refuses to run if it finds a value that is not in the mapping, so a value that appeared after this analysis is surfaced instead of guessed at.

### The task (lib/tasks/assessments.rake)
`rake assessments:normalize_legacy_statuses[company_id,dry_run]`
The task has a dry run option which is true by default. It prints old -> new counts and only `dry_run=false` writes to the database. An optional `company_id` allows us to run a small company first as a canary and work through the rest one company at a time. Rows are updated in batches with each batch being its own transaction and a short sleep between each batch. For idempotency, only rows whose status is still a legacy value is selected, so a stopped run can be restarted.

### Rollback strategy
We have added a migration to add two nullable columns to the table: `legacy_status` and `status_backfille_at`. The backfill copies the original status into `legacy_status` in the same update, and `rake assessments:restore_legacy_statuses[company_id]` restores `status` from `legacy_status` in the same batches. We would also implement a database backup on heorku with `heroku pg:backups:capture` immediately before the run. Using it as our restore mechanism is our last resort as it would lose every write made after the backup.

Before running the backfilling task, we would rehearse on a fork of the database using `heroku addons:create heroku-postgresql --fork` which would give us realistic timings and it would allow us to practise the rollback. We could also rely on the point-in-time recovery if the Heroku Postgres plan supports it.

### Release plan
While the app is live, we could safely run the migration which adds the two new columns and deploy the code which only writes valid statuses. We would also be able to run the dry run and review the counts.

During a low-traffic window (e.g. outside of office hours) we could capture and verify the database backup, run the canary company, and check the counts and the dashboard. If there are no issues there, we could run the remaining companies one at a time, and to verify that our backfill worked, we could run a distinct-status query which should only return valid statuses.

If something goes wrong, we could stop the task, run the rollback task for the affected comapny, and fall back to the backup only if this is not enough. In a later release, we could drop the `legacy_status` and `status_backfilled_at` columns after an agreed period of time.

## Use of AI
I used Claude to write the code for the solutions I had in mind. I asked it to implement validation on the Assessment model against a standardized set of valid status values.

My prompt for adding and validating against the standardized set of statuses: "I would like to start by adding a standard, valid set of statuses to the Assessment model, and to validate against that set so that new or existing assessments cannot be made or updated with invalid statuses. These valid statuses are as follows: pending, in_progress, completed, needs_follow_up, archived. Let's also add a test for this change."

Coming up with a solution for back-filling the assessment statuses involved a back and forth conversation with Claude, which started with the following prompt: "Now I would like to work on a plan for back-filling our existing assessments with invalid statuses to have correct statuses. My thinking is as follows: this would need to happen after hours, and it would likely need to be run in a rails task by an engineer. We would need to be able to easily rollback these changes too if anything went wrong. We could create a copy of our Heroku database before running this task, but I'd like to explore other options with you. We should also assume that the data we will be handling is possibly millions of rows, and so we should plan for that, possibly by running these changes in batches, such as for a specific company. We will need to define a mapping of invalid statuses to valid statuses, and for that we will need to know what the uniq statuses are in our database before we can define that mapping." Eventually, after a lot of back and forth, we came up with a solution that I believe is safe, correct and offers a suitable rollback strategy.
