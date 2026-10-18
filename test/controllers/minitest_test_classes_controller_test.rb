require "test_helper"

class MinitestTestClassesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:lazaro_nixon)
    @minitest_test_class = minitest_test_classes(:one)
  end

  test "should get index" do
    get minitest_test_classes_url
    assert_response :success
  end

  test "should get new" do
    get new_minitest_test_class_url
    assert_response :success
  end

  test "should create minitest_test_class" do
    assert_difference("MinitestTestClass.count") do
      post minitest_test_classes_url, params: {minitest_test_class: {class_name: @minitest_test_class.class_name}}
    end

    assert_redirected_to minitest_test_class_url(MinitestTestClass.last)
  end

  test "should show minitest_test_class" do
    get minitest_test_class_url(@minitest_test_class)
    assert_response :success
  end

  test "should get edit" do
    get edit_minitest_test_class_url(@minitest_test_class)
    assert_response :success
  end

  test "should update minitest_test_class" do
    patch minitest_test_class_url(@minitest_test_class), params: {minitest_test_class: {class_name: @minitest_test_class.class_name}}
    assert_redirected_to minitest_test_class_url(@minitest_test_class)
  end

  test "should destroy minitest_test_class" do
    assert_difference("MinitestTestClass.count", -1) do
      delete minitest_test_class_url(@minitest_test_class)
    end

    assert_redirected_to minitest_test_classes_url
  end
end
