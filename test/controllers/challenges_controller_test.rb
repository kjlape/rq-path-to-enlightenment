require "test_helper"

class ChallengesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:lazaro_nixon)
    @journey = journeys(:one)
    @challenge = challenges(:one)
  end

  test "should get index" do
    get journey_challenges_url(@journey)
    assert_response :success
  end

  test "should get new" do
    get new_journey_challenge_url(@journey)
    assert_response :success
  end

  test "should create challenge" do
    assert_difference("Challenge.count") do
      post journey_challenges_url(@journey), params: {challenge: {
        title: @challenge.title,
        description: @challenge.description,
        position: @challenge.position,
        challengeable_type: "MinitestTestClass",
        challengeable_attributes: {class_name: "SomeClass"}
      }}
    end

    assert_redirected_to journey_url(@journey)
  end

  test "should show challenge" do
    get challenge_url(@challenge)
    assert_response :success
  end

  test "should get edit" do
    get edit_challenge_url(@challenge)
    assert_response :success
  end

  test "should update challenge" do
    patch challenge_url(@challenge), params: {challenge: {
      title: @challenge.title,
      description: @challenge.description,
      position: @challenge.position,
      challengeable_type: "MinitestTestClass"
    }}
    assert_redirected_to journey_url(@journey)
  end

  test "should destroy challenge" do
    assert_difference("Challenge.count", -1) do
      delete challenge_url(@challenge)
    end

    assert_redirected_to journey_challenges_url(@journey)
  end
  test "non-admin cannot create challenge" do
    sign_in_as users(:one)
    assert_no_difference("Challenge.count") do
      post journey_challenges_url(@journey), params: { challenge: {title: "x", description: "y"}}
    end
    assert_redirected_to root_url
  end

  test "non-admin cannot edit challenge" do
    sign_in_as users(:one)
    get edit_challenge_url(challenges(:one))
    assert_redirected_to root_url
  end

  test "non-admin cannot destroy challenge" do
    sign_in_as users(:one)
    assert_no_difference("Challenge.count") do
      delete challenge_url(challenges(:one))
    end
    assert_redirected_to root_url
  end
end
