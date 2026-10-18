require "test_helper"

class ChallengeTest < ActiveSupport::TestCase
  test "new challenges default to a MinitestTestClass challengeable type" do
    assert_equal "MinitestTestClass", Challenge.new.challengeable_type
  end

  test "an explicit challengeable type wins over the default" do
    assert_equal "MinitestTestMethod", Challenge.new(challengeable_type: "MinitestTestMethod").challengeable_type
  end

  test "challenge_code renders the full challengeable source" do
    test_class = minitest_test_classes(:one)
    challenge = Challenge.create!(journey: journeys(:one), title: "c", description: "d", position: 0,
      challengeable: test_class, challengeable_type: "MinitestTestClass")

    assert_equal test_class.full_code, challenge.challenge_code
  end
end
