require "application_system_test_case"

class ChallengeAnswersTest < ApplicationSystemTestCase
  setup do
    @challenge_answer = challenge_answers(:one)
  end

  test "visiting the index" do
    visit challenge_answers_url
    assert_selector "h1", text: "Challenge answers"
  end

  test "should create challenge answer" do
    visit challenge_answers_url
    click_on "New challenge answer"

    fill_in "Challenge", with: @challenge_answer.challenge_id
    fill_in "Submitted code", with: @challenge_answer.submitted_code
    click_on "Create Challenge answer"

    assert_text "Challenge answer was successfully created"
    click_on "Back"
  end

  test "should update Challenge answer" do
    visit challenge_answer_url(@challenge_answer)
    click_on "Edit this challenge answer", match: :first

    fill_in "Challenge", with: @challenge_answer.challenge_id
    fill_in "Submitted code", with: @challenge_answer.submitted_code
    click_on "Update Challenge answer"

    assert_text "Challenge answer was successfully updated"
    click_on "Back"
  end

  test "should destroy Challenge answer" do
    visit challenge_answer_url(@challenge_answer)
    click_on "Destroy this challenge answer", match: :first

    assert_text "Challenge answer was successfully destroyed"
  end
end
