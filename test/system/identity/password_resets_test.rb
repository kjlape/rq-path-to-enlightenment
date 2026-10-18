require "application_system_test_case"

class Identity::PasswordResetsTest < ApplicationSystemTestCase
  setup do
    @user = users(:lazaro_nixon)
    @sid = @user.generate_token_for(:password_reset)
  end

  test "sending a password reset email" do
    visit sign_in_url
    click_on "Forgot your password?"
    # The click returns while Turbo is still navigating; the sign-in page also
    # has an "Email" field, so wait for the reset page to render before filling.
    assert_selector "h1", text: "Forgot your password?"

    fill_in "Email", with: @user.email
    # Guard against the Turbo submit racing the fill: without this, a click
    # that lands before the fill's change event submits an empty email and
    # bounces back to the form with the flash already consumed.
    assert_field "Email", with: @user.email
    click_on "Send password reset email"

    assert_text "Check your email for reset instructions"
  end

  test "updating password" do
    visit edit_identity_password_reset_url(sid: @sid)

    fill_in "New password", with: "Secret6*4*2*"
    fill_in "Confirm new password", with: "Secret6*4*2*"
    click_on "Save changes"

    assert_text "Your password was reset successfully. Please sign in"
  end
end
