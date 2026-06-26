class Calendar < ApplicationRecord
  belongs_to :user
  has_many :calendar_connections, dependent: :destroy
  has_many :calendar_blocks, dependent: :destroy
  has_many :block_schedules, dependent: :destroy

  validates :name, presence: true
end
