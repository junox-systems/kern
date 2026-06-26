class BlockSchedule < ApplicationRecord
  include HasCapability

  belongs_to :user
  belongs_to :calendar
  belongs_to :category
  has_many :calendar_blocks, dependent: :nullify

  validates :start_time, :end_time, presence: true
  validate :start_time_before_end_time
  validate :effective_range_valid
  validate :days_of_week_valid

  private

  def start_time_before_end_time
    return if start_time.blank? || end_time.blank?
    
    # In Active Record, time columns can be coerced into Time objects.
    # We compare the hour/min/sec components.
    t_start = start_time.is_a?(String) ? Time.zone.parse(start_time) : start_time
    t_end = end_time.is_a?(String) ? Time.zone.parse(end_time) : end_time
    
    # We compare formatted time or time representation
    if t_end.strftime("%H:%M:%S") <= t_start.strftime("%H:%M:%S")
      errors.add(:end_time, "must be after start time")
    end
  end

  def effective_range_valid
    return if effective_from.blank? || effective_until.blank?
    
    if effective_until < effective_from
      errors.add(:effective_until, "must be on or after effective_from")
    end
  end

  def days_of_week_valid
    if days_of_week.blank?
      errors.add(:days_of_week, "must include at least one day")
      return
    end

    # Handle stringified/JSON array if it comes in as a string
    array = days_of_week
    if array.is_a?(String)
      begin
        array = JSON.parse(array)
      rescue JSON::ParserError
        errors.add(:days_of_week, "is not a valid JSON array")
        return
      end
    end

    unless array.is_a?(Array) && array.all? { |d| (0..6).include?(d.to_i) }
      errors.add(:days_of_week, "must be an array of integers 0-6")
    end
  end
end
