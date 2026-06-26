class Category < ApplicationRecord
  belongs_to :user
  belongs_to :parent, class_name: "Category", optional: true
  has_many :subcategories, class_name: "Category", foreign_key: :parent_id, dependent: :destroy
  has_many :commitments, dependent: :nullify
  has_many :calendar_blocks, dependent: :destroy
  has_many :block_schedules, dependent: :destroy

  validates :name, presence: true

  MAX_DEPTH = 3

  before_save :compute_depth
  validate :max_depth
  validate :no_cycles

  private

  def compute_depth
    self.depth = parent ? parent.depth + 1 : 0
  end

  def max_depth
    # Temporary compute depth to check before save
    current_depth = parent ? parent.depth + 1 : 0
    if current_depth > MAX_DEPTH
      errors.add(:parent_id, "exceeds maximum nesting depth of #{MAX_DEPTH}")
    end
  end

  def no_cycles
    ancestor = parent
    while ancestor
      if id.present? && ancestor.id == id
        errors.add(:parent_id, "creates a cycle")
        break
      end
      ancestor = ancestor.parent
    end
  end
end
