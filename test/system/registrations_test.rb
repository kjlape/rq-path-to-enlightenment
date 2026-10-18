require "application_system_test_case"

class RegistrationsTest < ApplicationSystemTestCase
  test "signing up" do
    visit sign_up_url

    fill_in "Email", with: "lazaronixon@hey.com"
    fill_in "Password", with: "Secret6*4*2*"
    fill_in "Password confirmation", with: "Secret6*4*2*"
    # The nav also renders a "Sign up" link, so target the submit button
    # specifically instead of the ambiguous link-or-button match.
    click_button "Sign up"

    assert_text "Welcome! You have signed up successfully"
  end
end
