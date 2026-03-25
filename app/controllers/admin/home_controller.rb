class Admin::HomeController < ApplicationController
  layout 'admin'
  
  def index
    @products_count = Product.count
    @customers_count = Customer.count
    @orders_today_count = Order.where(created_at: Time.zone.today.all_day).count
    @pending_orders_count = Order.where(status: [:pending, :confirmed, :preparing, :ready, :out_for_delivery]).count
    @monthly_revenue = FinancialEntry.income.paid.where(occurred_on: Date.current.beginning_of_month..Date.current.end_of_month).sum(:amount)
    @monthly_expenses = FinancialEntry.expense.paid.where(occurred_on: Date.current.beginning_of_month..Date.current.end_of_month).sum(:amount)
    @monthly_profit = @monthly_revenue - @monthly_expenses
    @low_stock_products = Product.where("stock_quantity <= ?", 5).active_first.limit(5)
    @recent_orders = Order.includes(:customer).recent_first.limit(5)
    @recent_financial_entries = FinancialEntry.recent_first.limit(5)
  end
end
