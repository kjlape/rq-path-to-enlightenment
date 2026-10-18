class ChallengesController < ApplicationController
  before_action :set_journey, only: [:index, :new, :create]
  before_action :set_challenge, only: [:show, :edit, :update, :destroy]
  before_action :set_journey_from_challenge, only: [:update, :destroy]
  before_action :require_admin, only: [:new, :create, :edit, :update, :destroy]

  def index
    @challenges = @journey.challenges.order(:position)
  end

  def show
    @answer = Current.user.challenge_answers.find_by(challenge: @challenge)
  end

  def new
    @challenge = @journey.challenges.new
  end

  def create
    @challenge = @journey.challenges.new(challenge_params)

    if @challenge.save
      redirect_to journey_path(@journey), notice: "Challenge was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @challenge.update(challenge_params)
      redirect_to journey_path(@journey), notice: "Challenge was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @challenge.destroy
    redirect_to journey_challenges_path(@journey), notice: "Challenge was successfully destroyed."
  end

  private

  def set_journey_from_challenge
    @journey = @challenge.journey
  end

  def set_journey
    @journey = Journey.find(params[:journey_id])
    @challenge_scope = @journey.challenges
  end

  def set_challenge
    @challenge_scope ||= Challenge.all
    @challenge = @challenge_scope.find(params[:id])
  end

  def challenge_params
    params.require(:challenge).permit(:title, :description, :position, :challengeable_type, challengeable_attributes: [:class_name])
  end
end
