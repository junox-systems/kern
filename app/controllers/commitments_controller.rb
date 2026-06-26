class CommitmentsController < ApplicationController
  before_action :set_commitment, only: %i[ show edit update destroy ]

  # GET /commitments or /commitments.json
  def index
    @commitments = Commitment.all
  end

  # GET /commitments/1 or /commitments/1.json
  def show
  end

  # GET /commitments/new
  def new
    @commitment = Commitment.new
  end

  # GET /commitments/1/edit
  def edit
  end

  # POST /commitments or /commitments.json
  def create
    @commitment = Commitment.new(commitment_params)

    respond_to do |format|
      if @commitment.save
        format.html { redirect_to @commitment, notice: "Commitment was successfully created." }
        format.json { render :show, status: :created, location: @commitment }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @commitment.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /commitments/1 or /commitments/1.json
  def update
    respond_to do |format|
      if @commitment.update(commitment_params)
        format.html { redirect_to @commitment, notice: "Commitment was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @commitment }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @commitment.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /commitments/1 or /commitments/1.json
  def destroy
    @commitment.destroy!

    respond_to do |format|
      format.html { redirect_to commitments_path, notice: "Commitment was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_commitment
      @commitment = Commitment.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def commitment_params
      params.expect(commitment: [ :user_id, :category_id, :title, :description, :context, :capability, :estimate_minutes, :due_at, :available_after, :state ])
    end
end
