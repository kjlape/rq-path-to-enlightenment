require "test_helper"

class JourneyTest < ActiveSupport::TestCase
  setup do
    @user = users(:lazaro_nixon)
    @journey = Journey.create!(title: "Basics")
    @challenges = 2.times.map do |i|
      Challenge.create!(journey: @journey, title: "c#{i}", description: "d", position: i,
        challengeable: MinitestTestClass.create!(class_name: %w[AlphaTest BetaTest][i]))
    end
  end

  test "completion_percentage is 0 when the journey has no challenges" do
    assert_equal 0, Journey.create!(title: "Empty").completion_percentage(@user)
  end

  test "completion_percentage reflects the user's passing answers" do
    ChallengeAnswer.create!(user: @user, challenge: @challenges.first, submitted_code: "x", passed: true)

    assert_equal 50, @journey.completion_percentage(@user)
  end

  test "completion_percentage ignores non-passing answers" do
    ChallengeAnswer.create!(user: @user, challenge: @challenges.first, submitted_code: "x", passed: false)

    assert_equal 0, @journey.completion_percentage(@user)
  end

  test "completion_percentage is 100 when everything is passed" do
    @challenges.each { |c| ChallengeAnswer.create!(user: @user, challenge: c, submitted_code: "x", passed: true) }

    assert_equal 100, @journey.completion_percentage(@user)
  end
end
