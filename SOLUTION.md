# Task 1 Solution
## CSV export
I focused on implementing the streaming approach for the CSV generation. The main reason for this was because it would not require a background job queue, nor would it require a delivery step. The cost of this approach over an asynchronous approach is a tied up web thread, which waits for the CSV to finish generating before completing the request. I would switch to an asynchronous approach if CSV generation started taking minutes.

I also read the database objects into memory in batches as opposed to all at once.

## UI changes
I also implemented error handling for invalid filters like a date range that is reversed or a status that is invalid, with UI feedback to the user when trying to generate a CSV with these invalid filters. No CSV is generated until the filters are valid.

## Tests
These were added for the controller, and I would have added some more for the changes to the Assessment model.

## Use of AI
I used Claude to check my work against the Task 1 spec to ensure that there were no bugs and that I stuck to the spec. I also prompted it to apply the filter validations and UI changes to display the validation errors. I also asked it to write some basic tests for these changes.

My prompt for the filter validation and UI changes: "I want to add some request validation for the export so that an error message displays on the frontend when the filters are invalid (status not in valid options Assessment::VALID_STATUSES.include?(status) and date range valid). Please implement a basic version of that without committing the changes"

My prompt for adding the tests: "Please add some tests for this behaviour in AssessmentsController#export"
