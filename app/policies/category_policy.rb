# frozen_string_literal: true

class CategoryPolicy < ApplicationPolicy
  relation_scope do |relation|
    relation.where(user_id: user.id)
  end
end
