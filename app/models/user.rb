class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :email_address, presence: true, uniqueness: true
  validates :name, presence: true

  has_many :categories, dependent: :destroy
  has_many :commitments, dependent: :destroy
  has_many :operator_events, dependent: :destroy
  has_many :calendars, dependent: :destroy
  has_many :calendar_blocks, dependent: :destroy
  has_many :block_schedules, dependent: :destroy
end
