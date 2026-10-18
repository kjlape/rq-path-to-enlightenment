class MinitestTestMethod < ApplicationRecord
  include Formattable

  belongs_to :minitest_test_class
  validates :method_name, presence: true, format: {with: /\A[a-zA-Z_][a-zA-Z0-9_]*[?!=]?\z/}
  validates :method_body, presence: true

  before_create { self.position ||= (minitest_test_class.minitest_test_methods.maximum(:position) || -1) + 1 }

  def full_code
    <<~CODE
      def test_#{method_name}
      #{indent 2, method_body}
      end
    CODE
  end

  def full_code_with_class
    minitest_test_class.full_code(methods: [self])
  end

end
