require "application_system_test_case"

class MinitestTestMethodsTest < ApplicationSystemTestCase
  setup do
    @minitest_test_class = minitest_test_classes(:one)
    @minitest_test_method = minitest_test_methods(:one)
    sign_in_as users(:lazaro_nixon)
  end

  test "visiting the index" do
    visit minitest_test_class_minitest_test_methods_url(@minitest_test_class)
    assert_selector "h1", text: "Minitest test methods"
  end

  test "should create minitest test method" do
    visit minitest_test_class_minitest_test_methods_url(@minitest_test_class)
    click_on "New minitest test method"

    fill_in "Method name", with: "push"
    fill_in "Method body", with: @minitest_test_method.method_body
    click_on "Create Minitest test method"

    # The new form lives inside a Turbo Frame, so the create redirects within
    # the frame and the flash notice never reaches the page. Verify the
    # persisted record on the parent class page instead.
    visit minitest_test_class_url(@minitest_test_class)
    assert_text "push"
  end

  test "should update Minitest test method" do
    visit minitest_test_method_url(@minitest_test_method)
    click_on "Edit this minitest test method", match: :first

    fill_in "Method name", with: "pop"
    fill_in "Method body", with: @minitest_test_method.method_body
    click_on "Update Minitest test method"

    assert_text "Minitest test method was successfully updated"
    click_on "Back"
  end

  test "should destroy Minitest test method" do
    visit minitest_test_method_url(@minitest_test_method)
    click_on "Destroy this minitest test method", match: :first

    assert_text "Minitest test method was successfully destroyed"
  end
end
