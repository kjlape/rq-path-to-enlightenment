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

  test "should update minitest_test_class from edited code" do
    @minitest_test_class.minitest_test_methods.create!(method_name: "push", method_body: "assert true")

    patch minitest_test_class_url(@minitest_test_class), as: :json,
      params: {minitest_test_class: {code: <<~RUBY}}
        class MyString < Minitest::Test
          def test_push
            assert_equal 2, 1 + 1
          end
        end
      RUBY

    assert_response :ok
    assert_equal "assert_equal 2, 1 + 1", @minitest_test_class.minitest_test_methods.find_by!(method_name: "push").reload.method_body
  end

  test "should not update minitest_test_class from unrecognizable code" do
    patch minitest_test_class_url(@minitest_test_class), as: :json,
      params: {minitest_test_class: {code: "puts 'hello'"}}

    assert_response :unprocessable_entity
    assert_equal "MyString", @minitest_test_class.reload.class_name
  end

  test "should destroy minitest_test_class" do
    assert_difference("MinitestTestClass.count", -1) do
      delete minitest_test_class_url(@minitest_test_class)
    end

    assert_redirected_to minitest_test_classes_url
  end
  test "non-admin cannot create minitest_test_class" do
    sign_in_as users(:one)
    assert_no_difference("MinitestTestClass.count") do
      post minitest_test_classes_url, params: { minitest_test_class: {title: "x", description: "y"}}
    end
    assert_redirected_to root_url
  end

  test "non-admin cannot edit minitest_test_class" do
    sign_in_as users(:one)
    get edit_minitest_test_class_url(minitest_test_classes(:one))
    assert_redirected_to root_url
  end

  test "non-admin cannot destroy minitest_test_class" do
    sign_in_as users(:one)
    assert_no_difference("MinitestTestClass.count") do
      delete minitest_test_class_url(minitest_test_classes(:one))
    end
    assert_redirected_to root_url
  end
end
