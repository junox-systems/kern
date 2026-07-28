# frozen_string_literal: true

class BlockGenerationJob < ApplicationJob
  queue_as :default

  # Generates CalendarBlocks from active BlockSchedules for a window of days (default: next 7 days)
  def perform(days_ahead = 7)
    start_date = Date.current
    end_date = start_date + days_ahead.days

    BlockSchedule.where(active: true).find_each do |schedule|
      (start_date..end_date).each do |date|
        next if schedule.effective_from.present? && date < schedule.effective_from
        next if schedule.effective_until.present? && date > schedule.effective_until

        days = schedule.days_of_week
        days = JSON.parse(days) if days.is_a?(String)
        wday = date.wday # 0 (Sun) - 6 (Sat)
        next unless days.map(&:to_i).include?(wday)

        # Create block if not already generated from this schedule on this date
        CalendarBlock.find_or_create_by!(
          user_id: schedule.user_id,
          calendar_id: schedule.calendar_id,
          block_schedule_id: schedule.id,
          date: date
        ) do |block|
          block.category_id = schedule.category_id
          block.capability = schedule.capability
          block.start_time = schedule.start_time
          block.end_time = schedule.end_time
          block.block_type = :scheduled
        end
      end
    end
  end
end
