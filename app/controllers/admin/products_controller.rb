class Admin::ProductsController < ApplicationController
  layout 'admin'
  
  before_action :set_product, only: %i[ show update edit destroy ]
  before_action :set_categories, only: %i[show new create edit update]

  def index
    @q = Product.ransack(params[:q])
    @pagy, @products = pagy(@q.result.active_first, items: 8)
  end

  def show
    @product.images.build if @product.images.blank?
  end

  def new
    @product = Product.new
    @product.images.build
  end

  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to admin_products_path, notice: 'Produto criado com sucesso!' }
      else
        @product.images.build if @product.images.blank?
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @product.images.build if @product.images.blank?
  end

  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to admin_products_path, notice: "Produto atualizado com sucesso." }
      else
        @product.images.build if @product.images.blank?
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if @product.destroy
      redirect_to admin_products_path, notice: "Produto excluído com sucesso."
    else
      redirect_to admin_products_path, notice: "Ocorreu um erro. Tente novamente ou contate o administrador."
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def set_categories
    @categories = Category.all.map { |c| [c.description, c.id] }
  end

  def product_params
    params.require(:product).permit(:title, :description, :price, :identification_code, :stock_quantity, :featured, :active, :prep_time_minutes, :remove_old_image, :category_id, images_attributes: [ :id, :data, :_destroy ])
  end
end
