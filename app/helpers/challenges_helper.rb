module ChallengesHelper
  def challenge_form_model(challenge)
    challenge.persisted? ? challenge : [challenge.journey, challenge]
  end
end
