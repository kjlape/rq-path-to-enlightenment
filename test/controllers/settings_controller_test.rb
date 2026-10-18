require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:lazaro_nixon)
  end

  test "should get index" do
    get settings_url
    assert_response :success
  end
end
