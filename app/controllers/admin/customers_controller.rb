class Admin::CustomersController < ApplicationController
  layout "admin"

  before_action :set_customer, only: [:show]

  def index
    @q = Customer.ransack(params[:q])
    @pagy, @customers = pagy(@q.result.active_first, items: 8)
  end

  def show
    @orders = @customer.orders.includes(:order_items).recent_first
  end

  private

  def set_customer
    @customer = Customer.find(params[:id])
  end
end
