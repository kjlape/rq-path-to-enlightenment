require "test_helper"

class ChallengeAnswersControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:lazaro_nixon)
    @challenge_answer = challenge_answers(:one)
  end

  test "should get index" do
    get challenge_answers_url
    assert_response :success
  end

  test "should get new" do
    get new_challenge_answer_url
    assert_response :success
  end

  test "should create challenge_answer" do
    assert_difference("ChallengeAnswer.count") do
      post challenge_answers_url, params: {challenge_answer: {challenge_id: @challenge_answer.challenge_id, submitted_code: @challenge_answer.submitted_code, user_id: @challenge_answer.user_id}}
    end

    assert_redirected_to challenge_answer_url(ChallengeAnswer.last)
  end

  test "should show challenge_answer" do
    get challenge_answer_url(@challenge_answer)
    assert_response :success
  end

  test "should get edit" do
    get edit_challenge_answer_url(@challenge_answer)
    assert_response :success
  end

  test "should update challenge_answer" do
    patch challenge_answer_url(@challenge_answer), params: {challenge_answer: {challenge_id: @challenge_answer.challenge_id, submitted_code: @challenge_answer.submitted_code, user_id: @challenge_answer.user_id}}
    assert_redirected_to challenge_answer_url(@challenge_answer)
  end

  test "should destroy challenge_answer" do
    assert_difference("ChallengeAnswer.count", -1) do
      delete challenge_answer_url(@challenge_answer)
    end

    assert_redirected_to challenge_answers_url
  end
end
