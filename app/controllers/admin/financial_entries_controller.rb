class Admin::FinancialEntriesController < ApplicationController
  layout "admin"

  before_action :set_financial_entry, only: [:edit, :update, :destroy]

  def index
    @q = FinancialEntry.ransack(params[:q])
    @pagy, @financial_entries = pagy(@q.result.recent_first, items: 10)
    @monthly_income = FinancialEntry.income.paid.where(occurred_on: Date.current.beginning_of_month..Date.current.end_of_month).sum(:amount)
    @monthly_expenses = FinancialEntry.expense.paid.where(occurred_on: Date.current.beginning_of_month..Date.current.end_of_month).sum(:amount)
    @monthly_balance = @monthly_income - @monthly_expenses
  end

  def new
    @financial_entry = FinancialEntry.new(occurred_on: Date.current)
  end

  def create
    @financial_entry = FinancialEntry.new(financial_entry_params)

    if @financial_entry.save
      redirect_to admin_financial_entries_path, notice: "Lancamento cadastrado com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @financial_entry.update(financial_entry_params)
      redirect_to admin_financial_entries_path, notice: "Lancamento atualizado com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @financial_entry.destroy
    redirect_to admin_financial_entries_path, notice: "Lancamento removido com sucesso."
  end

  private

  def set_financial_entry
    @financial_entry = FinancialEntry.find(params[:id])
  end

  def financial_entry_params
    params.require(:financial_entry).permit(:title, :kind, :category, :amount, :occurred_on, :payment_status, :notes, :order_id)
  end
end
