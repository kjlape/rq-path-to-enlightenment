class AddPassedToChallengeAnswers < ActiveRecord::Migration[7.1]
  def change
    add_column :challenge_answers, :passed, :boolean, null: false, default: false
    # One answer per (user, challenge); re-running tests updates it in place.
    remove_index :challenge_answers, :challenge_id, if_exists: true
    add_index :challenge_answers, [:user_id, :challenge_id], unique: true
  end
end
