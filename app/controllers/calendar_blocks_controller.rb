class CalendarBlocksController < ApplicationController
  before_action :set_calendar_block, only: %i[ show edit update destroy ]

  # GET /calendar_blocks
  def index
    @calendar_blocks = Current.user.calendar_blocks
  end

  # GET /calendar_blocks/1
  def show
    authorize! @calendar_block
  end

  # GET /calendar_blocks/new
  def new
    @calendar_block = Current.user.calendar_blocks.build
  end

  # GET /calendar_blocks/1/edit
  def edit
    authorize! @calendar_block
  end

  # POST /calendar_blocks
  def create
    @calendar_block = Current.user.calendar_blocks.build(calendar_block_params)

    respond_to do |format|
      if @calendar_block.save
        format.html { redirect_to @calendar_block, notice: "Calendar block created." }
        format.json { render :show, status: :created, location: @calendar_block }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @calendar_block.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /calendar_blocks/1
  def update
    authorize! @calendar_block

    respond_to do |format|
      if @calendar_block.update(calendar_block_params)
        format.html { redirect_to @calendar_block, notice: "Calendar block updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @calendar_block }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @calendar_block.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /calendar_blocks/1
  def destroy
    authorize! @calendar_block
    @calendar_block.destroy!

    respond_to do |format|
      format.html { redirect_to calendar_blocks_path, notice: "Calendar block removed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  def set_calendar_block
    @calendar_block = Current.user.calendar_blocks.find(params.expect(:id))
  end

  def calendar_block_params
    params.expect(calendar_block: [ :calendar_id, :category_id, :block_schedule_id, :capability, :date, :start_time, :end_time, :block_type, :external_uid ])
  end
end
