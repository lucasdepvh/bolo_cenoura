class OrdersController < ApplicationController
  skip_before_action :authenticate_admin!
  protect_from_forgery with: :null_session, only: :create

  def create
    ActiveRecord::Base.transaction do
      customer = build_customer
      customer.save!

      order = customer.orders.build(order_attributes)
      order.status = :pending
      order.delivery_fee = delivery_fee_from_params
      order.discount = 0
      order.notes = checkout_params[:notes]
      order.scheduled_for = scheduled_for_from_params

      Array(checkout_params[:items]).each do |item|
        product = Product.find(item[:id])
        order.order_items.build(
          product: product,
          product_name: product.title,
          quantity: item[:quantity].to_i,
          unit_price: product.price
        )
      end

      order.save!

      render json: {
        order_code: order.code,
        whatsapp_url: whatsapp_url_for(order),
        message: "Pedido criado com sucesso."
      }, status: :created
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.to_sentence }, status: :unprocessable_entity
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Um dos produtos do carrinho nao foi encontrado." }, status: :unprocessable_entity
  end

  private

  def build_customer
    customer = Customer.find_or_initialize_by(phone: checkout_params[:phone])
    customer.assign_attributes(
      name: checkout_params[:name],
      email: checkout_params[:email],
      neighborhood: checkout_params[:neighborhood],
      address: checkout_params[:address],
      notes: checkout_params[:customer_notes]
    )
    customer
  end

  def order_attributes
    {
      fulfillment_type: checkout_params[:fulfillment_type],
      payment_method: checkout_params[:payment_method].presence || :pix
    }
  end

  def delivery_fee_from_params
    checkout_params[:delivery_fee].presence.to_f
  end

  def scheduled_for_from_params
    return Time.current if checkout_params[:scheduled_for].blank?

    Time.zone.parse(checkout_params[:scheduled_for])
  rescue ArgumentError
    Time.current
  end

  def checkout_params
    params.require(:order).permit(
      :name,
      :phone,
      :email,
      :neighborhood,
      :address,
      :customer_notes,
      :notes,
      :fulfillment_type,
      :payment_method,
      :scheduled_for,
      :delivery_fee,
      items: [:id, :quantity]
    )
  end

  def whatsapp_url_for(order)
    message = +"Ola, acabei de montar o pedido #{order.code} no site da Casa do bolo de cenoura:%0A"

    order.order_items.each do |item|
      message << "- #{item.product_name} x #{item.quantity} | #{ApplicationController.helpers.number_to_currency(item.total_price)}%0A"
    end

    message << "%0ATotal: #{ApplicationController.helpers.number_to_currency(order.total_amount)}"
    message << "%0ACliente: #{order.customer.name}"
    message << "%0ATelefone: #{order.customer.phone}"
    message << "%0AEntrega: #{order.fulfillment_type_label}"

    "https://wa.me/5569992791505?text=#{message}"
  end
end
