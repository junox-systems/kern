require "test_helper"

class CommitmentDependencyTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @commitment1 = Commitment.create!(user: @user, title: "Comm 1")
    @commitment2 = Commitment.create!(user: @user, title: "Comm 2")
    @commitment3 = Commitment.create!(user: @user, title: "Comm 3")
  end

  test "cannot depend on itself" do
    dep = CommitmentDependency.new(commitment: @commitment1, depends_on: @commitment1)
    assert_not dep.valid?
    assert_includes dep.errors[:depends_on_id], "cannot depend on itself"
  end

  test "prevents simple cycles" do
    CommitmentDependency.create!(commitment: @commitment1, depends_on: @commitment2)
    
    dep = CommitmentDependency.new(commitment: @commitment2, depends_on: @commitment1)
    assert_not dep.valid?
    assert_includes dep.errors[:depends_on_id], "creates a dependency cycle"
  end

  test "prevents deep cycles" do
    CommitmentDependency.create!(commitment: @commitment1, depends_on: @commitment2)
    CommitmentDependency.create!(commitment: @commitment2, depends_on: @commitment3)
    
    dep = CommitmentDependency.new(commitment: @commitment3, depends_on: @commitment1)
    assert_not dep.valid?
    assert_includes dep.errors[:depends_on_id], "creates a dependency cycle"
  end

  test "validates uniqueness of dependency" do
    CommitmentDependency.create!(commitment: @commitment1, depends_on: @commitment2)
    
    dep = CommitmentDependency.new(commitment: @commitment1, depends_on: @commitment2)
    assert_not dep.valid?
    assert_includes dep.errors[:depends_on_id], "has already been taken"
  end
end
