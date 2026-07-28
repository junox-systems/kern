require "test_helper"

class OperatorTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    operator = Operator.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", operator.email_address)
  end
end
