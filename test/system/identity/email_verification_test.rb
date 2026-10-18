require "application_system_test_case"

class Identity::EmailVerificationTest < ApplicationSystemTestCase
  test "banner is hidden when the user's email is verified" do
    sign_in_as users(:lazaro_nixon)

    assert_no_text "Verify your email."
    assert_no_button "Resend verification email"

    visit minitest_test_classes_url

    assert_no_text "Verify your email."
    assert_no_button "Resend verification email"
  end

  test "banner shows on every page and resend works for unverified users" do
    sign_in_as users(:unverified_user)

    assert_text "Verify your email."
    assert_button "Resend verification email"

    click_on "Resend verification email"

    assert_text "We sent a verification email to your email address"

    visit minitest_test_classes_url

    assert_text "Verify your email."
    assert_button "Resend verification email"
  end

  test "password reset blocked for an unverified email explains and links to resend" do
    visit sign_in_url
    click_on "Forgot your password?"
    assert_button "Send password reset email"

    fill_in "Email", with: users(:unverified_user).email
    click_on "Send password reset email"

    assert_text "Your email isn't verified yet"
    assert_text "You can't reset your password until you verify your email"
    assert_button "Resend verification email"
  end
end
