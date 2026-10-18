class ChallengeAnswersController < ApplicationController
  before_action :set_challenge_answer, only: %i[show edit update destroy]

  # GET /challenge_answers or /challenge_answers.json
  def index
    @challenge_answers = Current.user.challenge_answers
  end

  # GET /challenge_answers/1 or /challenge_answers/1.json
  def show
  end

  # GET /challenge_answers/new
  def new
    @challenge_answer = ChallengeAnswer.new
  end

  # GET /challenge_answers/1/edit
  def edit
  end

  # POST /challenge_answers or /challenge_answers.json
  # Upserts: there is one answer per (user, challenge), so a new run that
  # passes updates the existing answer instead of creating a duplicate.
  # `passed` is only accepted here — from the editor's test runner — never
  # from the plain form.
  def create
    @challenge_answer = Current.user.challenge_answers
      .find_or_initialize_by(challenge_id: run_params[:challenge_id])
    @challenge_answer.assign_attributes(run_params)

    respond_to do |format|
      if @challenge_answer.save
        format.html { redirect_to challenge_answer_url(@challenge_answer), notice: "Challenge answer was successfully created." }
        format.json { render :show, status: :created, location: @challenge_answer }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @challenge_answer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /challenge_answers/1 or /challenge_answers/1.json
  def update
    respond_to do |format|
      if @challenge_answer.update(challenge_answer_params)
        format.html { redirect_to challenge_answer_url(@challenge_answer), notice: "Challenge answer was successfully updated." }
        format.json { render :show, status: :ok, location: @challenge_answer }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @challenge_answer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /challenge_answers/1 or /challenge_answers/1.json
  def destroy
    @challenge_answer.destroy!

    respond_to do |format|
      format.html { redirect_to challenge_answers_url, notice: "Challenge answer was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_challenge_answer
    @challenge_answer = Current.user.challenge_answers.find(params[:id])
  end

  # The user is set from the current session, never from params.
  def challenge_answer_params
    params.require(:challenge_answer).permit(:challenge_id, :submitted_code)
  end

  # Params for a run submission: everything above plus the runner's verdict.
  def run_params
    params.require(:challenge_answer).permit(:challenge_id, :submitted_code, :passed)
  end
end
