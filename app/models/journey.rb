class Journey < ApplicationRecord
  has_many :challenges, -> { order(position: :asc) }, dependent: :destroy

  validates :title, presence: true

  # Percentage of this journey's challenges the user has a passing answer for.
  def completion_percentage(user)
    total = challenges.count
    return 0 if total.zero?

    # The unique (user_id, challenge_id) index guarantees one row per pair,
    # so a plain count of passing answers is the passed-challenge count.
    passed = user.challenge_answers.where(challenge_id: challenge_ids, passed: true).count
    (passed * 100.0 / total).round
  end

  def self.new_from_minitest_test_class(record)
    journey = new(
      title: record.title,
      description: record.description
    )

    journey.challenges = record.minitest_test_methods.map.with_index do |method, index|
      Challenge.new_from_minitest_test_method(method, journey: journey, position: index)
    end

    journey
  end
end
