class User < ApplicationRecord
  has_secure_password

  generates_token_for :email_verification, expires_in: 2.days do
    email
  end
  generates_token_for :password_reset, expires_in: 20.minutes do
    password_salt.last(10)
  end

  has_many :sessions, dependent: :destroy
  has_many :recovery_codes, dependent: :destroy
  has_many :challenge_answers, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: {with: URI::MailTo::EMAIL_REGEXP}
  validates :password, allow_nil: true, length: {minimum: 12}
  validates :password, not_pwned: {message: "might easily be guessed"}

  normalizes :email, with: -> { _1.strip.downcase }

  before_validation if: :email_changed?, on: :update do
    self.verified = false
  end

  before_validation on: :create do
    self.otp_secret = ROTP::Base32.random
  end

  after_update if: :password_digest_previously_changed? do
    sessions.where.not(id: Current.session).delete_all
  end

  def overall_completion
    # TODO: Implement actual calculation
    50.0 # Returning a stub value of 50%
  end

  def journeys
    # TODO: Implement actual association with user's journeys
    Journey.all # Returning all journeys as a stub
  end

  def username
    email.split("@").first
  end
end
