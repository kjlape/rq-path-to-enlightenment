require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]

  def sign_in_as(user)
    visit sign_in_url
    # Wait for the Turbo navigation to settle so fill_in targets this page's
    # fields, not a stale page. Capybara waiting semantics only — no sleeps.
    assert_selector "h1", text: "Sign in"
    fill_in :email, with: user.email
    fill_in :password, with: "Secret1*3*5*"
    # Guard against the Turbo submit racing the fill (click before the fill's
    # change event registers would submit an empty form and hang on HTML5
    # validation). Capybara waiting semantics only — no hard sleeps.
    assert_field :email, with: user.email
    assert_field :password, with: "Secret1*3*5*"
    click_on "Sign in"

    assert_current_path root_url
    user
  end
end
