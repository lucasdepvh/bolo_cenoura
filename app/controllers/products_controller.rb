class ProductsController < ApplicationController
    skip_before_action :authenticate_admin!
    
    def show
        @product = Product.find(params[:id])
        Product.increment_counter(:views_count, @product.id)
        @product.reload
        @relateds_products = Product.where(active: true).related_to(@product)[0..3]
    end
end
