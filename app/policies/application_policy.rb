# frozen_string_literal: true

class ApplicationPolicy < ActionPolicy::Base
  # Configure inherit_relations_scope to true to enable relation scoping inheritance
  # inherit_relations_scope

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
    record.respond_to?(:operator_id) && record.operator_id == operator.id
  end
end
