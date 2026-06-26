class CommitmentDependency < ApplicationRecord
  belongs_to :commitment
  belongs_to :depends_on, class_name: "Commitment"

  validates :depends_on_id, uniqueness: { scope: :commitment_id }
  validate :prevent_cycles

  private

  def prevent_cycles
    return if commitment_id.blank? || depends_on_id.blank?

    if commitment_id == depends_on_id
      errors.add(:depends_on_id, "cannot depend on itself")
      return
    end

    # Check if the depends_on commitment depends on the source commitment (creates a cycle)
    visited = Set.new([depends_on_id])
    queue = [depends_on]

    while queue.any?
      current = queue.shift
      next unless current

      if current.dependencies.exists?(id: commitment_id)
        errors.add(:depends_on_id, "creates a dependency cycle")
        return
      end

      current.dependencies.each do |dep|
        unless visited.include?(dep.id)
          visited.add(dep.id)
          queue << dep
        end
      end
    end
  end
end
