class HomeController < ApplicationController
  include Pagy::Backend

  skip_before_action :authenticate_admin!

  def index
    @q = Product.where(active: true).ransack(params[:q] || {})
    @pagy, @products = pagy(@q.result.active_first, items: 9)
    @featured_products = Product.where(active: true, featured: true).active_first.limit(3)
  end

  def who_we_are
  end
end
