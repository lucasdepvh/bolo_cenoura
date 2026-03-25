class Admin::CategoriesController < ApplicationController
  layout 'admin'
  
  before_action :set_category, only: %i[ update edit destroy ]

  def index
    @q = Category.ransack(params[:q])
    @pagy, @categories = pagy(@q.result, items: 5)
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)

    respond_to do |format|
      if @category.save
        format.html { redirect_to admin_categories_path, notice: 'Categoria criada com sucesso!' }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @category.update(category_params)
        format.html { redirect_to admin_categories_path, notice: "Categoria atualizada com sucesso." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if @category.destroy
      redirect_to admin_categories_path, notice: "Categoria excluída com sucesso."
    else
      redirect_to admin_categories_path, notice: "Ocorreu um erro. Tente novamente ou contate o administrador."
    end
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:description)
  end
end
