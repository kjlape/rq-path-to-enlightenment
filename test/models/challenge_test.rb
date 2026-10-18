require "test_helper"

class ChallengeTest < ActiveSupport::TestCase
  test "new challenges default to a MinitestTestClass challengeable type" do
    assert_equal "MinitestTestClass", Challenge.new.challengeable_type
  end

  test "an explicit challengeable type wins over the default" do
    assert_equal "MinitestTestMethod", Challenge.new(challengeable_type: "MinitestTestMethod").challengeable_type
  end
end
