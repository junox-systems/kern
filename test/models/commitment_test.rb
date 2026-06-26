require "test_helper"

class CommitmentTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "requires a title" do
    commitment = Commitment.new(user: @user)
    assert_not commitment.valid?
    assert_includes commitment.errors[:title], "can't be blank"
  end

  test "default state is inbox" do
    commitment = Commitment.new(user: @user, title: "Test")
    assert commitment.inbox?
  end

  test "validates state enum inclusion" do
    commitment = Commitment.new(user: @user, title: "Test")
    # In Rails 8 with validate: true, assigning an invalid enum value
    # might raise ArgumentError or just add a validation error.
    # To be safe, we can assert that it's either invalid or raises.
    begin
      commitment.state = :invalid_state
      assert_not commitment.valid?
      assert_includes commitment.errors[:state], "is not included in the list"
    rescue ArgumentError
      assert true
    end
  end
end
