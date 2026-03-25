class Admin::OrdersController < ApplicationController
  layout "admin"

  before_action :set_order, only: [:show]

  def index
    @q = Order.includes(:customer).ransack(params[:q])
    @pagy, @orders = pagy(@q.result.includes(:customer).recent_first, items: 8)
  end

  def show
  end

  def update
    @order = Order.includes(:customer, :order_items, :financial_entries).find(params[:id])

    if @order.update(order_params)
      redirect_to admin_order_path(@order), notice: "Pedido atualizado com sucesso."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_order
    @order = Order.includes(:customer, :order_items, :financial_entries).find(params[:id])
  end

  def order_params
    params.require(:order).permit(:status, :payment_method, :fulfillment_type, :scheduled_for, :delivered_at, :delivery_fee, :discount, :notes)
  end
end
