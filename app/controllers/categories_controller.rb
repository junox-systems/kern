class CategoriesController < ApplicationController
  before_action :set_category, only: %i[ show edit update destroy ]

  # GET /categories
  def index
    @categories = Current.operator.categories
  end

  # GET /categories/1
  def show
    authorize! @category
  end

  # GET /categories/new
  def new
    @category = Current.operator.categories.build
  end

  # GET /categories/1/edit
  def edit
    authorize! @category
  end

  # POST /categories
  def create
    @category = Current.operator.categories.build(category_params)

    respond_to do |format|
      if @category.save
        format.html { redirect_to @category, notice: "Category created." }
        format.json { render :show, status: :created, location: @category }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @category.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /categories/1
  def update
    authorize! @category

    respond_to do |format|
      if @category.update(category_params)
        format.html { redirect_to @category, notice: "Category updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @category }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @category.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /categories/1
  def destroy
    authorize! @category
    @category.destroy!

    respond_to do |format|
      format.html { redirect_to categories_path, notice: "Category removed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  def set_category
    @category = Current.operator.categories.find(params.expect(:id))
  end

  def category_params
    params.expect(category: [ :parent_id, :name, :description, :priority, :weekly_allocation_minutes ])
  end
end
