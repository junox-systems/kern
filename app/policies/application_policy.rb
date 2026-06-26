# frozen_string_literal: true

class ApplicationPolicy < ActionPolicy::Base
  # Configure inherit_relations_scope to true to enable relation scoping inheritance
  # inherit_relations_scope

  # Default rule: Only allow access if the record belongs to the user
  def show?
    own_record?
  end

  def edit?
    show?
  end

  def update?
    show?
  end

  def destroy?
    show?
  end

  private

  def own_record?
    # Ensure record has a user_id and it matches the current user
    record.respond_to?(:user_id) && record.user_id == user.id
  end
end
