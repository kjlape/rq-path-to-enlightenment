class Challenge < ApplicationRecord
  belongs_to :journey

  delegated_type :challengeable, types: %w[MinitestTestClass MinitestTestMethod]
  has_many :challenge_answers, dependent: :destroy
  validates :challengeable_type, presence: true, inclusion: {in: %w[MinitestTestClass MinitestTestMethod]}
  accepts_nested_attributes_for :challengeable

  def initialize(attributes = nil)
    super
    self.challengeable_type ||= default_challengeable_type
  end

  def default_challengeable_type
    MinitestTestClass.name
  end

  validates :title, presence: true
  validates :description, presence: true
  validates :position, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0}
  def challenge_code
    challengeable.challenge_code
  end

  # What the editor starts from: the user's last submission, or the pristine
  # challenge source if they have not submitted one.
  def starter_code(answer = nil)
    answer&.submitted_code.presence || challenge_code
  end

  def self.new_from_minitest_test_method(record, journey:, position:)
    new(
      title: record.method_name,
      description: record.method_body,
      challengeable: record,
      challengeable_type: record.class.name,
      journey: journey,
      position: position
    )
  end
end
