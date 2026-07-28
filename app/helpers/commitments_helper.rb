module CommitmentsHelper
  def state_badge_class(state)
    case state.to_sym
    when :inbox then "badge-ghost"
    when :ready then "badge-info"
    when :blocked then "badge-warning"
    when :done then "badge-success"
    when :archived then "badge-neutral"
    else "badge-ghost"
    end
  end

  def human_due_date(due_at)
    return nil if due_at.blank?

    diff_hours = (due_at - Time.current) / 1.hour
    if diff_hours <= 0
      "Overdue"
    elsif diff_hours <= 24
      "Due today"
    elsif diff_hours <= 48
      "Due tomorrow"
    else
      "Due #{due_at.strftime('%b %-d')}"
    end
  end
end
