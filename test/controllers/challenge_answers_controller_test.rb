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
    challenge = Challenge.create!(journey: journeys(:one), title: "Fresh", description: "d", position: 0,
      challengeable: MinitestTestClass.create!(class_name: "FreshTest"))

    assert_difference("ChallengeAnswer.count") do
      post challenge_answers_url, params: {challenge_answer: {challenge_id: challenge.id, submitted_code: "x"}}
    end

    assert_redirected_to challenge_answer_url(ChallengeAnswer.last)
    assert_equal users(:lazaro_nixon).id, ChallengeAnswer.last.user_id
  end

  test "a passing run upserts the existing answer instead of duplicating it" do
    @challenge_answer.update!(passed: false)

    assert_no_difference("ChallengeAnswer.count") do
      post challenge_answers_url, params: {challenge_answer: {challenge_id: @challenge_answer.challenge_id, submitted_code: "better code", passed: true}}, as: :json
    end

    assert_response :created
    @challenge_answer.reload
    assert_equal "better code", @challenge_answer.submitted_code
    assert @challenge_answer.passed?
  end

  test "should show challenge_answer" do
    get challenge_answer_url(@challenge_answer)
    assert_response :success
  end

  test "should get edit" do
    get edit_challenge_answer_url(@challenge_answer)
    assert_response :success
  end

  test "should update challenge_answer without un-passing it" do
    @challenge_answer.update!(passed: true)

    patch challenge_answer_url(@challenge_answer), params: {challenge_answer: {challenge_id: @challenge_answer.challenge_id, submitted_code: "edited", passed: false}}
    assert_redirected_to challenge_answer_url(@challenge_answer)
    assert @challenge_answer.reload.passed?, "edits must not un-pass a challenge"
  end

  test "should destroy challenge_answer" do
    assert_difference("ChallengeAnswer.count", -1) do
      delete challenge_answer_url(@challenge_answer)
    end

    assert_redirected_to challenge_answers_url
  end
end
