Senior Full-Stack Developer (Ruby on Rails)
Technical Vetting Assignment
Instructions & Requirements
Take-Home Assignment: Safely Extending a Legacy Rails Feature (4-hour scope)
Context
You’re taking over a 10-year-old Ruby on Rails app used by companies to manage ergonomic/health assessments for their
employees. You inherit a small but realistic slice around “Assessments” with typical legacy rough edges. Your job is to add a
commonly requested export, make one targeted performance improvement, and design a safe data change plan — without
rewrites.
What’s known about the current module (based on observed behavior and logs):
• CSV export can pull assessments for any company when given a company identifier; it includes raw answer data and personal
identifiers.
• The assessments dashboard is slow with many records; filtering by date and status is inconsistent, and the displayed score is
sometimes blank or obviously off.
• Logs include full request parameters and occasionally raw assessment data.
• The status field has many inconsistent values accumulated over years (for example: empty string, nil, “n/a”, “complete”, “comp”,
“done”, “pending”, “in_progress”, “needs_follow_up”, “archived”).
Business and data context:
• Multi-tenant: company admins must only see and export their own company’s data.
• Health-related data: treat data handling and logging with extra care.
• The assessments table is large; avoid changes that would stall the app.
• You own your release lifecycle (Heroku-like environment) and should think through a safe rollout and rollback.
Assume entities roughly include: companies, employees (belong to a company), and assessments (belong to an employee
and company) with fields such as company_id, employee_id, employee_email, status, responses_json, created_at.
Core technologies to use:
• Ruby on Rails
• PostgreSQL
• TypeScript
Operate with restraint. Favor targeted, safe improvements over broad refactors. Preserve what works while adding clear
value.
Requirements
Design and implement the following. Keep the scope tight and pragmatic. You may create minimal scaffolding as needed,
but keep the UI and any new structures small and focused.
Task 1: Company-Scoped CSV Export with Focused Filters and Redactions
Add or revise CSV export so that:
• A company admin can export assessments for their own company only.
• Filters are limited to exactly two: date range and status.
• The exported file excludes or redacts fields that should not leave the system in raw form (for example, free-text answers and
personal identifiers).
• Provide a minimal UI to initiate the export (TypeScript) with basic feedback to the user.
Notes:
• Either a streaming or an asynchronous approach is acceptable; choose one, keep it minimal, and justify it in SOLUTION.md.
• Do not rely on a client-provided company identifier to grant access.
• Avoid exposing sensitive values in logs related to this feature.
Task 2: Make the Assessments Dashboard Snappier and Fix the Score Display
Company admins report the dashboard page is slow and that the score shown is sometimes blank or wrong. Improve the
experience without changing what the page fundamentally shows.
Do the following:
• Achieve one measurable performance improvement that helps with larger data sets. In SOLUTION.md, include a short before/after
note on how you measured and why you chose this change.
• Ensure the score displayed for each assessment is consistently present and correct under normal circumstances.
• Reduce the chance of sensitive information being written to logs in this area.
Constraints:
• Keep the page working while you improve it.
• Avoid broad refactors; make the smallest reasonable change to achieve the goal.
Task 3: Normalize Assessment Status Values With a Safe Release Plan (Plan-Only Backfill)
Production should standardize status values going forward to:
• pending
• in_progress
• completed
• needs_follow_up
• archived
Do the following:
• Implement a change so new and updated records use only the allowed values.
• Design, but do not fully execute, a plan to bring historical records into alignment. Outline how you would map existing values to
the new set and how you would handle unknowns.
• In SOLUTION.md, provide a step-by-step release and rollback plan suitable for a Heroku-like environment, including how you would
capture a database backup before the change and how you would recover if needed. Clarify which steps are safe to run while the
app is live and which you’d schedule during a low-traffic window.
Constraints:
• Keep the app responsive throughout.
• Avoid changes that would lock or stall the large assessments table.
Scope control:
• Keep TypeScript truly minimal (small UI to trigger export and show basic feedback).
• Automated tests are optional; focus on correctness, safety, and SOLUTION.md.
Deliverables
1. A single GitHub repository containing:
• All the source code for the assignment
• A README.md with instructions to run locally.
• A SOLUTION.md describing the design and trade-offs you made.
2. Video Demo (5-10 minutes using Loom or similar):
• Demonstrate the working project by doing a voice over
• Walk through your code architecture
• Explain key design decisions and any trade-offs made
• Highlight interesting technical implementations
Time Estimate
This should take ±4 hours to complete, but you can take as long as you need.
