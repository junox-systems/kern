class Commitment < ApplicationRecord
  include HasCapability

  belongs_to :user
  belongs_to :category, optional: true

  has_many :commitment_dependencies, dependent: :destroy
  has_many :dependencies, through: :commitment_dependencies, source: :depends_on

  has_many :inverse_commitment_dependencies, class_name: "CommitmentDependency", foreign_key: :depends_on_id, dependent: :destroy
  has_many :dependents, through: :inverse_commitment_dependencies, source: :commitment

  has_many :operator_events, dependent: :destroy

  enum :state, {
    inbox:    0,
    ready:    1,
    blocked:  2,
    done:     3,
    archived: 4
  }, default: :inbox, validate: true

  validates :title, presence: true
end
