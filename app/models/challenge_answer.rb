class ChallengeAnswer < ApplicationRecord
  belongs_to :user
  belongs_to :challenge

  # One answer per user per challenge — re-running the tests updates it in place.
  validates :user_id, uniqueness: {scope: :challenge_id}
end
