class Journey < ApplicationRecord
  has_many :challenges, -> { order(position: :asc) }, dependent: :destroy

  validates :title, presence: true

  # Percentage of this journey's challenges the user has a passing answer for.
  def completion_percentage(user)
    total = challenges.count
    return 0 if total.zero?

    passed = user.challenge_answers.where(challenge_id: challenge_ids, passed: true)
      .select(:challenge_id).distinct.count
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
