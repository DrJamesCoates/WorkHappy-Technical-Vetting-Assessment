# Task 2 Solution
## Page load performance improvement
I focused on two changes to improve the page loading times here - add pagination, which arguably added the biggest time page load improvement, and I fixed an N+1 query in the view.

Before adding these two changes, the page consistently took more than 10 seconds to load. However, after these changes, the page loaded within a second.

## Consistently displaying the assessment overall scores
I decided to move the method that calculates the average score for an assessment to the model as I think it makes sense that this method should exist there. I also asked Claude to add a comment to explain what the method does. I wanted to standardize what key in the key-value pair inside `responses_json` is associated with a score value, and I wanted to ensure we made the validation rules for these scores explicit. I made sure to treat `nil`, negative numbers, and strings containing chars that were not numbers as invalid and to not include them in the average score calculation. The result of this calculation is displayed in the table and only scenarios where it was absolutely impossible to calculate the score (ie. none of the q1-q10 keys contained a valid value) do we display a dash as opposed to a number.

## Reduce the chance of writing sensitive information to the logs
I removed the logs for the params and the assessment attributes. I also filter parameters globally, avoid logging record contents and keep production log level at `:info`.

## Use of AI
I used Claude to write the code for the solutions I had in mind. I asked it to implement pagination on the table, and then I asked it to fix the N+1 query that was present in the view. I then addressed the obvious issues I could see with the score calculation by prompting it to implement the solution I had in mind.

My prompt for adding pagination to the UI: "I have checked out a new branch for task-2. I would like to start the improvements on the snappiness of this page by adding some basic pagination to the assessments displayed in the table. This should be applied to the AssessmentsController#index action. Filters should always be applied first before paginating. Do not commit these changes once you have made them. Let's use will_paginate for this pagination behaviour, and let's give the user more options in terms of customizing the per_page value."
This was then followed with: "Please add some basic styling to improve the look of the interface of this pagination component, and remove the pagination component from the top of the table - I prefer having it at the bottom."

I addressed the N+1 query present in the view with this prompt: "There is also an N+1 query on the employee name in the view - please add a .includes(:employee) to the query in the controller."

My prompt for resolving the issues with the scores:
Let's start by moving the #assessment_score helper method into the Assessment model. Change the name of the method to average_assessment_score and add a comment that the method returns the average of the scores for q1 - q10 where nils and invalid strings or numbers are treated as blank and excluded from the average. Where the values for q1 - q10 are truly all blank or invalid, we can return nil. Nil answers should not count as 0, invalid numbers are any numbers less than zero, and invalid strings are any strings that are not positive numbers. Let's assume that the score values may be floats and therefore we should call .to_f on each value if present and valid. We can round the average score off to the nearest decimal, and we can look specifically for the values where the keys are "q1"-"q10". In the view, if the return value from the #avergae_assessment_score method is nil, display a "-" (dash).

My prompt for ensuring we don't log sensitive information: "Please add filtered params to the AssessmentsController. Also, please ensure we are not logging sensitive information in any of the other controllers besides AssessmentsController."
