class CalendarConnection < ApplicationRecord
  belongs_to :calendar
  has_one :user, through: :calendar

  encrypts :access_token, :refresh_token

  validates :provider, presence: true
end
