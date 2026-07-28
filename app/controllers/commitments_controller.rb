class CommitmentsController < ApplicationController
  before_action :set_commitment, only: %i[ show edit update destroy complete defer archive ]

  # GET /commitments
  def index
    @commitments = Current.operator.commitments
  end

  # GET /commitments/1
  def show
    authorize! @commitment
  end

  # GET /commitments/new
  def new
    @commitment = Current.operator.commitments.build
  end

  # GET /commitments/1/edit
  def edit
    authorize! @commitment
  end

  # POST /commitments
  def create
    @commitment = Current.operator.commitments.build(commitment_params)
    @commitment.state = :inbox

    respond_to do |format|
      if @commitment.save
        @commitment.operator_events.create!(
          operator: Current.operator,
          event_type: :capture
        )
        format.html { redirect_to @commitment, notice: "Commitment captured." }
        format.json { render :show, status: :created, location: @commitment }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @commitment.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /commitments/1
  def update
    authorize! @commitment

    respond_to do |format|
      if @commitment.update(commitment_params)
        format.html { redirect_to @commitment, notice: "Commitment updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @commitment }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @commitment.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /commitments/1
  def destroy
    authorize! @commitment
    @commitment.destroy!

    respond_to do |format|
      format.html { redirect_to commitments_path, notice: "Commitment removed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  # POST /commitments/1/complete
  def complete
    authorize! @commitment

    @commitment.done!
    @commitment.operator_events.create!(
      operator: Current.operator,
      event_type: :complete,
      metadata: { completed_at: Time.current.iso8601 }
    )

    # Unblock dependents whose dependencies are all done
    @commitment.dependents.each do |dependent|
      if dependent.blocked? && dependent.dependencies.all?(&:done?)
        dependent.ready!
      end
    end

    respond_to do |format|
      format.html { redirect_to commitments_path, notice: "Commitment completed.", status: :see_other }
      format.turbo_stream
      format.json { render :show, status: :ok, location: @commitment }
    end
  end

  # POST /commitments/1/defer
  def defer
    authorize! @commitment

    defer_until = params[:available_after] || 1.day.from_now
    @commitment.update!(available_after: defer_until)
    @commitment.operator_events.create!(
      operator: Current.operator,
      event_type: :defer,
      metadata: { deferred_until: defer_until.to_s }
    )

    respond_to do |format|
      format.html { redirect_to commitments_path, notice: "Commitment deferred.", status: :see_other }
      format.turbo_stream
      format.json { render :show, status: :ok, location: @commitment }
    end
  end

  # POST /commitments/1/archive
  def archive
    authorize! @commitment

    @commitment.archived!
    @commitment.operator_events.create!(
      operator: Current.operator,
      event_type: :archive
    )

    respond_to do |format|
      format.html { redirect_to commitments_path, notice: "Commitment archived.", status: :see_other }
      format.turbo_stream
      format.json { render :show, status: :ok, location: @commitment }
    end
  end

  private

  def set_commitment
    @commitment = Current.operator.commitments.find(params.expect(:id))
  end

  def commitment_params
    params.expect(commitment: [ :category_id, :title, :description, :context, :capability, :estimate_minutes, :due_at, :available_after ])
  end
end
