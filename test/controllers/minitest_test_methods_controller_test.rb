require "test_helper"

class MinitestTestMethodsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:lazaro_nixon)
    @minitest_test_class = minitest_test_classes(:one)
    @minitest_test_method = minitest_test_methods(:one)
  end

  test "should get index" do
    get minitest_test_class_minitest_test_methods_url(@minitest_test_class)
    assert_response :success
  end

  test "should get new" do
    get new_minitest_test_class_minitest_test_method_url(@minitest_test_class)
    assert_response :success
  end

  test "should create minitest_test_method" do
    assert_difference("MinitestTestMethod.count") do
      post minitest_test_class_minitest_test_methods_url(@minitest_test_class), params: {minitest_test_method: {method_body: "assert_equal 2, 1 + 1", method_name: "adds_numbers"}}
    end

    assert_redirected_to minitest_test_class_url(@minitest_test_class)
  end

  test "should show minitest_test_method" do
    get minitest_test_method_url(@minitest_test_method)
    assert_response :success
  end

  test "should get edit" do
    get edit_minitest_test_method_url(@minitest_test_method)
    assert_response :success
  end

  test "should update minitest_test_method" do
    patch minitest_test_method_url(@minitest_test_method), params: {minitest_test_method: {method_body: "assert_equal 4, 2 + 2", method_name: "adds_more_numbers"}}
    assert_redirected_to minitest_test_method_url(@minitest_test_method)
  end

  test "should destroy minitest_test_method" do
    assert_difference("MinitestTestMethod.count", -1) do
      delete minitest_test_method_url(@minitest_test_method)
    end

    assert_redirected_to minitest_test_class_url(@minitest_test_method.minitest_test_class)
  end
end
