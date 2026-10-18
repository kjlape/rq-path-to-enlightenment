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
      post challenge_answers_url, params: {challenge_answer: {challenge_id: @challenge_answer.challenge_id, submitted_code: @challenge_answer.submitted_code}}
    end

    assert_redirected_to challenge_answer_url(ChallengeAnswer.last)
    assert_equal users(:lazaro_nixon).id, ChallengeAnswer.last.user_id
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
    patch challenge_answer_url(@challenge_answer), params: {challenge_answer: {challenge_id: @challenge_answer.challenge_id, submitted_code: @challenge_answer.submitted_code}}
    assert_redirected_to challenge_answer_url(@challenge_answer)
  end

  test "should destroy challenge_answer" do
    assert_difference("ChallengeAnswer.count", -1) do
      delete challenge_answer_url(@challenge_answer)
    end

    assert_redirected_to challenge_answers_url
  end

  test "index lists only the current user's answers" do
    get challenge_answers_url
    assert_response :success
    assert_no_match(/OtherUsersCode/, @response.body)
  end

  test "cannot show another user's answer" do
    get challenge_answer_url(challenge_answers(:two))
    assert_response :not_found
  end

  test "cannot edit another user's answer" do
    get edit_challenge_answer_url(challenge_answers(:two))
    assert_response :not_found
  end

  test "cannot update another user's answer" do
    patch challenge_answer_url(challenge_answers(:two)), params: {challenge_answer: {submitted_code: "hacked"}}
    assert_response :not_found
    assert_equal "OtherUsersCode", challenge_answers(:two).reload.submitted_code
  end

  test "cannot destroy another user's answer" do
    assert_no_difference("ChallengeAnswer.count") do
      delete challenge_answer_url(challenge_answers(:two))
    end
    assert_response :not_found
  end

  test "create ignores user_id and assigns the current user" do
    assert_difference("ChallengeAnswer.count") do
      post challenge_answers_url, params: {challenge_answer: {challenge_id: challenges(:one).id, submitted_code: "puts 1", user_id: users(:one).id}}
    end

    assert_equal users(:lazaro_nixon), ChallengeAnswer.last.user
  end
end
