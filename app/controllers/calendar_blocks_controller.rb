class CalendarBlocksController < ApplicationController
  before_action :set_calendar_block, only: %i[ show edit update destroy ]

  # GET /calendar_blocks or /calendar_blocks.json
  def index
    @calendar_blocks = CalendarBlock.all
  end

  # GET /calendar_blocks/1 or /calendar_blocks/1.json
  def show
  end

  # GET /calendar_blocks/new
  def new
    @calendar_block = CalendarBlock.new
  end

  # GET /calendar_blocks/1/edit
  def edit
  end

  # POST /calendar_blocks or /calendar_blocks.json
  def create
    @calendar_block = CalendarBlock.new(calendar_block_params)

    respond_to do |format|
      if @calendar_block.save
        format.html { redirect_to @calendar_block, notice: "Calendar block was successfully created." }
        format.json { render :show, status: :created, location: @calendar_block }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @calendar_block.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /calendar_blocks/1 or /calendar_blocks/1.json
  def update
    respond_to do |format|
      if @calendar_block.update(calendar_block_params)
        format.html { redirect_to @calendar_block, notice: "Calendar block was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @calendar_block }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @calendar_block.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /calendar_blocks/1 or /calendar_blocks/1.json
  def destroy
    @calendar_block.destroy!

    respond_to do |format|
      format.html { redirect_to calendar_blocks_path, notice: "Calendar block was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_calendar_block
      @calendar_block = CalendarBlock.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def calendar_block_params
      params.expect(calendar_block: [ :user_id, :calendar_id, :category_id, :block_schedule_id, :capability, :date, :start_time, :end_time, :block_type, :external_uid ])
    end
end
