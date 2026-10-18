require "test_helper"

class MinitestTestClassTest < ActiveSupport::TestCase
  test "update_from_code saves edited method bodies and adds new methods" do
    minitest_test_class = MinitestTestClass.create!(class_name: "StackTest")
    minitest_test_class.minitest_test_methods.create!(method_name: "push", method_body: "assert true")

    code = <<~RUBY
      class StackTest < Minitest::Test
        def test_push
          assert_equal 1, Stack.new.push
        end

        def test_pop
          flunk
        end
      end
    RUBY

    assert minitest_test_class.update_from_code(code)

    push = minitest_test_class.minitest_test_methods.find_by!(method_name: "push")
    assert_equal "assert_equal 1, Stack.new.push", push.method_body
    assert_equal "flunk", minitest_test_class.minitest_test_methods.find_by!(method_name: "pop").method_body
  end

  test "update_from_code removes methods removed from the code" do
    minitest_test_class = MinitestTestClass.create!(class_name: "StackTest")
    removed = minitest_test_class.minitest_test_methods.create!(method_name: "push", method_body: "assert true")
    kept = minitest_test_class.minitest_test_methods.create!(method_name: "pop", method_body: "flunk")

    code = <<~RUBY
      class StackTest < Minitest::Test
        def test_pop
          flunk
        end
      end
    RUBY

    assert minitest_test_class.update_from_code(code)
    assert_not MinitestTestMethod.exists?(removed.id)
    assert_equal kept.id, minitest_test_class.minitest_test_methods.sole.id
  end

  test "update_from_code saves the class name from the code" do
    minitest_test_class = MinitestTestClass.create!(class_name: "StackTest")

    code = <<~RUBY
      class StackStuffTest < Minitest::Test
        def test_push
          assert true
        end
      end
    RUBY

    assert minitest_test_class.update_from_code(code)
    assert_equal "StackStuffTest", minitest_test_class.reload.class_name
  end

  test "full_code round-trips through update_from_code" do
    minitest_test_class = MinitestTestClass.create!(class_name: "StackTest")
    minitest_test_class.minitest_test_methods.create!(method_name: "push", method_body: "stack = Stack.new\nassert_equal 1, stack.push\nflunk")
    minitest_test_class.minitest_test_methods.create!(method_name: "pop", method_body: "if true\n  assert true\nend")

    original_code = minitest_test_class.full_code
    assert minitest_test_class.update_from_code(original_code)
    assert_equal original_code, minitest_test_class.reload.full_code
  end

  test "update_from_code rejects code it cannot map back to the class" do
    minitest_test_class = MinitestTestClass.create!(class_name: "StackTest")
    minitest_test_class.minitest_test_methods.create!(method_name: "push", method_body: "assert true")

    refute minitest_test_class.update_from_code("puts 'hello'")
    assert_predicate minitest_test_class.errors, :any?
    assert_equal "StackTest", minitest_test_class.reload.class_name
    assert_equal "assert true", minitest_test_class.minitest_test_methods.sole.method_body
  end

  test "update_from_code surfaces validation errors without saving anything" do
    minitest_test_class = MinitestTestClass.create!(class_name: "StackTest")
    minitest_test_class.minitest_test_methods.create!(method_name: "push", method_body: "assert true")

    code = <<~RUBY
      class StackTest < Minitest::Test
        def test_push
        end
      end
    RUBY

    assert_not minitest_test_class.update_from_code(code)
    assert minitest_test_class.errors.full_messages.any? { |message| message.include?("Method body can't be blank") }
    assert_equal "assert true", minitest_test_class.minitest_test_methods.sole.reload.method_body
  end

  test "update_from_code surfaces invalid class names" do
    minitest_test_class = MinitestTestClass.create!(class_name: "StackTest")

    code = <<~RUBY
      class Stack_Test < Minitest::Test
        def test_push
          assert true
        end
      end
    RUBY

    assert_not minitest_test_class.update_from_code(code)
    assert minitest_test_class.errors.full_messages.any? { |message| message.include?("Class name is invalid") }
  end
end
