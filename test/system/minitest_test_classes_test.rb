require "application_system_test_case"

class MinitestTestClassesTest < ApplicationSystemTestCase
  setup do
    @minitest_test_class = minitest_test_classes(:one)
    sign_in_as users(:lazaro_nixon)
  end

  test "visiting the index" do
    visit minitest_test_classes_url
    assert_selector "h1", text: "Minitest test classes"
  end

  test "should create minitest test class" do
    visit minitest_test_classes_url
    click_on "New minitest test class"

    fill_in "Class name", with: @minitest_test_class.class_name
    click_on "Create Minitest test class"

    assert_text "Minitest test class was successfully created"
    click_on "Back"
  end

  test "should update Minitest test class" do
    visit minitest_test_class_url(@minitest_test_class)
    click_on "Edit this minitest test class", match: :first

    fill_in "Class name", with: @minitest_test_class.class_name
    click_on "Update Minitest test class"

    assert_text "Minitest test class was successfully updated"
    click_on "Back"
  end

  test "should destroy Minitest test class" do
    visit minitest_test_class_url(@minitest_test_class)
    click_on "Destroy this minitest test class", match: :first

    assert_text "Minitest test class was successfully destroyed"
  end
end
