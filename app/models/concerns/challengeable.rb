module Challengeable
  extend ActiveSupport::Concern

  included do
    has_many :challenges, as: :challengeable, dependent: :destroy
  end

  # Add any common methods or validations for challengeable objects here

  # The full Ruby source shown in the challenge editor. Each challengeable
  # type decides what "the whole challenge" means for itself.
  # @return [String]
  def challenge_code
    raise NotImplementedError, "#{self.class} must implement #challenge_code"
  end
end
