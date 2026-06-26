require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @root = Category.create!(user: @user, name: "Root")
  end

  test "requires a name" do
    category = Category.new(user: @user, name: "")
    assert_not category.valid?
    assert_includes category.errors[:name], "can't be blank"
  end

  test "prevents self as parent cycle" do
    @root.parent = @root
    assert_not @root.valid?
    assert_includes @root.errors[:parent_id], "creates a cycle"
  end

  test "prevents deep cycles in hierarchy" do
    child = Category.create!(user: @user, name: "Child", parent: @root)
    grandchild = Category.create!(user: @user, name: "Grandchild", parent: child)

    @root.parent = grandchild
    assert_not @root.valid?
    assert_includes @root.errors[:parent_id], "creates a cycle"
  end

  test "enforces max depth" do
    level1 = Category.create!(user: @user, name: "L1", parent: @root)
    level2 = Category.create!(user: @user, name: "L2", parent: level1)
    level3 = Category.create!(user: @user, name: "L3", parent: level2)

    level4 = Category.new(user: @user, name: "L4", parent: level3)
    assert_not level4.valid?
    assert_includes level4.errors[:parent_id], "exceeds maximum nesting depth of 3"
  end

  test "computes depth correctly" do
    child = Category.create!(user: @user, name: "Child", parent: @root)
    assert_equal 1, child.depth
    
    grandchild = Category.create!(user: @user, name: "Grandchild", parent: child)
    assert_equal 2, grandchild.depth
  end
end
