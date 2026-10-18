require "test_helper"

class ChallengeAnswerTest < ActiveSupport::TestCase
  test "a user has at most one answer per challenge" do
    user = users(:lazaro_nixon)
    challenge = challenges(:one)
    ChallengeAnswer.create!(user: users(:unverified_user), challenge: challenge, submitted_code: "x")

    duplicate = ChallengeAnswer.new(user: user, challenge: challenge, submitted_code: "y")

    assert_not duplicate.valid?
    assert duplicate.errors.of_kind?(:user_id, :taken)
  end
end
