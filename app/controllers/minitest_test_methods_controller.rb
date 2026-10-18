class MinitestTestMethodsController < ApplicationController
  before_action :set_minitest_test_class, only: %i[index new create]
  before_action :set_minitest_test_method, only: %i[show edit update destroy]
  before_action :set_parent_minitest_test_class, only: %i[edit update]
  before_action :require_admin, only: %i[new create edit update destroy]

  # GET /minitest_test_methods or /minitest_test_methods.json
  def index
    @minitest_test_methods = @minitest_test_class.minitest_test_methods
  end

  # GET /minitest_test_methods/1 or /minitest_test_methods/1.json
  def show
  end

  # GET /minitest_test_methods/new
  def new
    @minitest_test_method = MinitestTestMethod.new
  end

  # GET /minitest_test_methods/1/edit
  def edit
  end

  # POST /minitest_test_methods or /minitest_test_methods.json
  def create
    @minitest_test_method = @minitest_test_class.minitest_test_methods.new(minitest_test_method_params)

    respond_to do |format|
      if @minitest_test_method.save
        format.html { redirect_to minitest_test_class_url(@minitest_test_class), notice: "Minitest test method was successfully created." }
        format.json { render :show, status: :created, location: @minitest_test_method }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @minitest_test_method.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /minitest_test_methods/1 or /minitest_test_methods/1.json
  def update
    respond_to do |format|
      if @minitest_test_method.update(minitest_test_method_params)
        format.html { redirect_to minitest_test_method_url(@minitest_test_method), notice: "Minitest test method was successfully updated." }
        format.json { render :show, status: :ok, location: @minitest_test_method }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @minitest_test_method.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /minitest_test_methods/1 or /minitest_test_methods/1.json
  def destroy
    @minitest_test_method.destroy!

    respond_to do |format|
      format.html { redirect_to minitest_test_class_url(@minitest_test_method.minitest_test_class), notice: "Minitest test method was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_minitest_test_method
    @minitest_test_method = MinitestTestMethod.find(params[:id])
  end

  def set_parent_minitest_test_class
    @minitest_test_class = @minitest_test_method.minitest_test_class
  end

  def set_minitest_test_class
    @minitest_test_class = MinitestTestClass.find(params[:minitest_test_class_id])
  end

  # Only allow a list of trusted parameters through.
  def minitest_test_method_params
    params.require(:minitest_test_method).permit(:method_name, :method_body)
  end
end
