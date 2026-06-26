# frozen_string_literal: true

class CommitmentPolicy < ApplicationPolicy
  # Scopes relations to only the current user's records
  relation_scope do |relation|
    relation.where(user_id: user.id)
  end
end
