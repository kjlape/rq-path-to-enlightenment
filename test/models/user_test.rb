require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @user = users(:lazaro_nixon)
    @journey = Journey.create!(title: "Basics")
    @challenges = 2.times.map do |i|
      Challenge.create!(journey: @journey, title: "c#{i}", description: "d", position: i,
        challengeable: MinitestTestClass.create!(class_name: %w[AlphaTest BetaTest][i]))
    end
  end

  test "overall_completion is 0 with no answers" do
    ChallengeAnswer.delete_all

    assert_equal 0.0, @user.overall_completion
  end

  test "overall_completion is the answered share of all challenges" do
    ChallengeAnswer.delete_all
    ChallengeAnswer.create!(user: @user, challenge: @challenges.first, submitted_code: "x")

    # 1 of every challenge (fixtures + the 2 created in setup)
    assert_equal (100.0 / Challenge.count).round(1), @user.overall_completion
  end

  test "journeys returns only journeys the user has answered in" do
    ChallengeAnswer.delete_all
    ChallengeAnswer.create!(user: @user, challenge: @challenges.first, submitted_code: "x")

    assert_equal [@journey.id], @user.journeys.map(&:id)
  end

  test "totp is built from the user's secret with the app issuer" do
    assert_equal @user.otp_secret, @user.totp.secret
    assert_equal "RubyPathToEnlightenment", @user.totp.issuer
  end
end
