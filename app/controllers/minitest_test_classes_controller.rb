class MinitestTestClassesController < ApplicationController
  before_action :set_minitest_test_class, only: %i[show edit update destroy]
  before_action :require_admin, only: %i[new create edit update destroy]

  # GET /minitest_test_classes or /minitest_test_classes.json
  def index
    @minitest_test_classes = MinitestTestClass.all
  end

  # GET /minitest_test_classes/1 or /minitest_test_classes/1.json
  def show
  end

  # GET /minitest_test_classes/new
  def new
    @minitest_test_class = MinitestTestClass.new
  end

  # GET /minitest_test_classes/1/edit
  def edit
  end

  # POST /minitest_test_classes or /minitest_test_classes.json
  def create
    @minitest_test_class = MinitestTestClass.new(minitest_test_class_params)

    respond_to do |format|
      if @minitest_test_class.save
        format.html { redirect_to minitest_test_class_url(@minitest_test_class), notice: "Minitest test class was successfully created." }
        format.json { render :show, status: :created, location: @minitest_test_class }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @minitest_test_class.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /minitest_test_classes/1 or /minitest_test_classes/1.json
  def update
    saved = if (code = minitest_test_class_params[:code]).present?
      @minitest_test_class.update_from_code(code)
    else
      @minitest_test_class.update(minitest_test_class_params.except(:code))
    end

    respond_to do |format|
      if saved
        format.html { redirect_to minitest_test_class_url(@minitest_test_class), notice: "Minitest test class was successfully updated." }
        format.json { render :show, status: :ok, location: @minitest_test_class }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @minitest_test_class.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /minitest_test_classes/1 or /minitest_test_classes/1.json
  def destroy
    @minitest_test_class.destroy!

    respond_to do |format|
      format.html { redirect_to minitest_test_classes_url, notice: "Minitest test class was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_minitest_test_class
    @minitest_test_class = MinitestTestClass.find(params[:id])
  end

  # Only allow a list of trusted parameters through. +code+ carries the edited
  # class source from the code editor and is handled by update_from_code, never
  # assigned as a plain attribute.
  def minitest_test_class_params
    params.require(:minitest_test_class).permit(:class_name, :code)
  end
end
