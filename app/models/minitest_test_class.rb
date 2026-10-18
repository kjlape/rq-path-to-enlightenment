class MinitestTestClass < ApplicationRecord
  include Formattable
  include Challengeable

  CLASS_HEADER = /\A\s*class\s+(?<class_name>[A-Z]\w*)\s*<\s*Minitest::Test\s*\z/
  CLASS_END = /\A\s*end\s*\z/
  METHOD_DEFINITION = /\A(?<indent>\s*)def\s+(?<method_name>test_[a-zA-Z0-9_]+[?!=]?)\s*(?:\(\s*\))?\s*\z/

  has_many :minitest_test_methods, -> { order(:position) }, dependent: :destroy
  validates :class_name, presence: true, format: {with: /\A[A-Z][a-zA-Z]*\z/}

  def full_code(methods: minitest_test_methods)
    <<~CODE
      class #{class_name} < Minitest::Test
    #{indent 2, methods.map(&:full_code).join("\n")}
      end
    CODE
  end

  # Replaces the class's stored data with the given editor code (same shape as
  # #full_code). Saves the class name, updates or creates the methods found in
  # the code, and removes methods that are no longer present. Everything happens
  # in one transaction, so a failure leaves the stored data untouched. Returns
  # true on success, or false with errors populated on anything invalid.
  def update_from_code(code)
    parsed = self.class.parse_code(code)
    unless parsed
      errors.add(:base, "Couldn't save the code. Expected a class definition like " \
        "\"class ExampleTest < Minitest::Test\" containing \"def test_something\" methods.")
      return false
    end

    self.class.transaction do
      update!(class_name: parsed[:class_name])

      kept_ids = parsed[:methods].each_with_index.map do |attributes, index|
        minitest_test_methods.find_or_initialize_by(method_name: attributes[:method_name]).tap do |method|
          method.update!(attributes.merge(position: index))
        end.id
      end

      minitest_test_methods.where.not(id: kept_ids).destroy_all
    end
    true
  rescue ActiveRecord::RecordInvalid => e
    errors.add(:base, e.record.errors.full_messages.to_sentence)
    false
  end

  # Parses editor code in the shape produced by #full_code:
  #
  #   class StackTest < Minitest::Test
  #     def test_push
  #       ...
  #     end
  #   end
  #
  # Returns {class_name:, methods: [{method_name:, method_body:}]} or nil when the
  # code doesn't match that shape. Anything unrecognizable is rejected rather than
  # silently dropped, so callers never persist a lossy interpretation.
  def self.parse_code(code)
    lines = code.to_s.lines.map(&:rstrip)
    header = lines.index { |line| line.match?(CLASS_HEADER) }
    closing = lines.rindex { |line| line.match?(CLASS_END) }
    return unless header && closing

    methods = parse_methods(lines[(header + 1)...closing])
    return unless methods

    {class_name: lines[header][CLASS_HEADER, :class_name], methods: methods}
  end

  def self.parse_methods(lines)
    methods = []
    index = 0
    while index < lines.length
      if (definition = lines[index].match(METHOD_DEFINITION))
        closing = closing_end_index(lines, index + 1, definition[:indent].length)
        return unless closing

        body = lines[(index + 1)...closing]
          .map { |line| line.sub(/\A {#{definition[:indent].length + 2}}/, "") }
          .join("\n")
        methods << {method_name: definition[:method_name].delete_prefix("test_"), method_body: body}
        index = closing + 1
      elsif lines[index].blank?
        index += 1
      else
        return # unrecognized content between methods
      end
    end
    methods
  end

  def self.closing_end_index(lines, from, indent)
    pattern = /\A {#{indent}}end\s*\z/
    (from...lines.length).find { |index| lines[index].match?(pattern) }
  end

  def title
    class_name
  end

  def challenge_code
    full_code
  end

  def description
    "TODO: Write a description for #{class_name}"
  end
end
