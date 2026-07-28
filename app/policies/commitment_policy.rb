# frozen_string_literal: true

class CommitmentPolicy < ApplicationPolicy
  relation_scope do |relation|
    relation.where(operator_id: operator.id)
  end
end
