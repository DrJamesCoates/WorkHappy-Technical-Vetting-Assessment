module AssessmentsHelper
  def status_badge(status)
    case status
    when "completed", "complete" then "green"
    when "pending" then "orange"
    when "in_progress" then "blue"
    end
  end
end
