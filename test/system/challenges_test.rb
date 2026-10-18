require "application_system_test_case"

class ChallengesTest < ApplicationSystemTestCase
  setup do
    @challenge = challenges(:one)
    @journey = journeys(:one)
    sign_in_as users(:lazaro_nixon)
  end

  test "visiting the index" do
    visit journey_challenges_url(@journey)
    assert_selector "h1", text: "Challenges"
  end

  test "should create challenge" do
    visit journey_challenges_url(@journey)
    click_on "New challenge"

    fill_in "Title", with: @challenge.title
    fill_in "Description", with: @challenge.description
    fill_in "Position", with: @challenge.position
    fill_in "Class name", with: @challenge.challengeable.class_name
    click_on "Create Challenge"

    assert_text "Challenge was successfully created"
    click_on "Back"
  end

  test "should update Challenge" do
    visit challenge_url(@challenge)
    click_on "Edit this challenge", match: :first

    fill_in "Title", with: @challenge.title
    fill_in "Description", with: @challenge.description
    fill_in "Position", with: @challenge.position
    fill_in "Class name", with: @challenge.challengeable.class_name
    click_on "Update Challenge"

    assert_text "Challenge was successfully updated"
    click_on "Back"
  end

  test "should destroy Challenge" do
    visit challenge_url(@challenge)
    click_on "Destroy this challenge", match: :first

    assert_text "Challenge was successfully destroyed"
  end
end
