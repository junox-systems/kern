class CalendarBlock < ApplicationRecord
  include HasCapability

  belongs_to :user
  belongs_to :calendar
  belongs_to :category
  belongs_to :block_schedule, optional: true

  enum :block_type, {
    scheduled: 0,  # Generated from a BlockSchedule
    manual:    1,  # Created ad-hoc by operator
    synced:    2   # Imported from external calendar (Google)
  }, default: :scheduled, validate: true

  validates :date, :start_time, :end_time, presence: true
  validate :start_time_before_end_time

  private

  def start_time_before_end_time
    return if start_time.blank? || end_time.blank?

    t_start = start_time.is_a?(String) ? Time.zone.parse(start_time) : start_time
    t_end = end_time.is_a?(String) ? Time.zone.parse(end_time) : end_time

    if t_end.strftime("%H:%M:%S") <= t_start.strftime("%H:%M:%S")
      errors.add(:end_time, "must be after start time")
    end
  end
end
