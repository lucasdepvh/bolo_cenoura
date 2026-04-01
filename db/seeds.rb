puts "Iniciando seed..."

admin_email = ENV.fetch("SEED_ADMIN_EMAIL", "admin@casadobolodecenoura.com")
admin_password = ENV.fetch("SEED_ADMIN_PASSWORD", "123456")

admin_accounts = [
  { email: admin_email, password: admin_password },
  { email: "max@gmail.com", password: "bolo@cenoura" }
]

created_admins = 0

admin_accounts.each do |attrs|
  admin = Admin.find_or_initialize_by(email: attrs[:email])
  if admin.new_record?
    admin.password = attrs[:password]
    admin.password_confirmation = attrs[:password]
    created_admins += 1
  end
  admin.save!
end

old_demo_codes = %w[ANL- BRC- PLS- CLR- PNG-]
Product.where(
  old_demo_codes.map { |prefix| "identification_code LIKE '#{prefix}%'" }.join(" OR ")
).destroy_all
Category.where("description LIKE ?", "%925%").destroy_all

catalogo = {
  "Tradicionais" => [
    { code: "BOLO-001", title: "Bolo de cenoura tradicional", price: 32.90, description: "Massa fofinha com cobertura cremosa de chocolate.", stock_quantity: 12, prep_time_minutes: 70, featured: true },
    { code: "BOLO-002", title: "Bolo de cenoura com brigadeiro", price: 38.90, description: "Versao classica com camada generosa de brigadeiro artesanal.", stock_quantity: 8, prep_time_minutes: 90, featured: true }
  ],
  "Recheados" => [
    { code: "BOLO-003", title: "Bolo vulcao de cenoura", price: 46.90, description: "Bolo com cobertura abundante escorrendo por toda a lateral.", stock_quantity: 6, prep_time_minutes: 100, featured: false },
    { code: "BOLO-004", title: "Bolo de cenoura com doce de leite", price: 42.50, description: "Receita para quem gosta de contraste entre cenoura e doce de leite.", stock_quantity: 5, prep_time_minutes: 95, featured: false }
  ],
  "Festas e encomendas" => [
    { code: "BOLO-005", title: "Bolo de cenoura para aniversario", price: 79.90, description: "Opcao maior para festas, com acabamento especial e decoracao simples.", stock_quantity: 3, prep_time_minutes: 180, featured: true },
    { code: "BOLO-006", title: "Mini bolo de cenoura", price: 18.90, description: "Ideal para presente, cafe individual ou lembrancinha.", stock_quantity: 15, prep_time_minutes: 45, featured: false }
  ]
}

created_products = 0

catalogo.each do |category_name, products|
  category = Category.find_or_create_by!(description: category_name)

  products.each do |attrs|
    product = Product.find_or_initialize_by(identification_code: attrs[:code])
    product.category = category
    product.title = attrs[:title]
    product.description = attrs[:description]
    product.price = attrs[:price]
    product.stock_quantity = attrs[:stock_quantity]
    product.prep_time_minutes = attrs[:prep_time_minutes]
    product.featured = attrs[:featured]
    product.active = true
    created_products += 1 if product.new_record?
    product.save!
  end
end

clientes = [
  { name: "Mariana Souza", phone: "(69) 99911-2233", email: "mariana@email.com", neighborhood: "Centro", address: "Rua das Flores, 120", notes: "Prefere entrega depois das 16h." },
  { name: "Carlos Henrique", phone: "(69) 99234-8899", email: "carlos@email.com", neighborhood: "Jardim America", address: "Av. Brasil, 550", notes: "Sempre paga no Pix." },
  { name: "Ana Paula", phone: "(69) 98123-4567", email: "ana@email.com", neighborhood: "Nova Porto Velho", address: "Rua Aroeira, 88", notes: "Cliente recorrente de aniversarios." }
]

clientes.each do |attrs|
  Customer.find_or_create_by!(phone: attrs[:phone]) do |customer|
    customer.name = attrs[:name]
    customer.email = attrs[:email]
    customer.neighborhood = attrs[:neighborhood]
    customer.address = attrs[:address]
    customer.notes = attrs[:notes]
  end
end

if Order.count.zero?
  pedido_1 = Order.create!(
    customer: Customer.find_by!(phone: "(69) 99911-2233"),
    status: :preparing,
    fulfillment_type: :delivery,
    payment_method: :pix,
    scheduled_for: 1.day.from_now.change(hour: 15),
    delivery_fee: 6.0,
    discount: 0,
    notes: "Cobertura extra de chocolate."
  )
  pedido_1.order_items.create!(product: Product.find_by!(identification_code: "BOLO-002"), product_name: "Bolo de cenoura com brigadeiro", quantity: 1, unit_price: 38.90)
  pedido_1.order_items.create!(product: Product.find_by!(identification_code: "BOLO-006"), product_name: "Mini bolo de cenoura", quantity: 2, unit_price: 18.90)
  pedido_1.save!

  pedido_2 = Order.create!(
    customer: Customer.find_by!(phone: "(69) 99234-8899"),
    status: :delivered,
    fulfillment_type: :pickup,
    payment_method: :cash,
    scheduled_for: 2.days.ago.change(hour: 10),
    delivered_at: 2.days.ago.change(hour: 10, min: 30),
    delivery_fee: 0,
    discount: 4.0,
    notes: "Retirada no balcao."
  )
  pedido_2.order_items.create!(product: Product.find_by!(identification_code: "BOLO-005"), product_name: "Bolo de cenoura para aniversario", quantity: 1, unit_price: 79.90)
  pedido_2.save!

  FinancialEntry.find_or_create_by!(title: "Venda #{pedido_1.code}") do |entry|
    entry.kind = :income
    entry.category = "Pedidos online"
    entry.amount = pedido_1.total_amount
    entry.occurred_on = Date.current
    entry.payment_status = :pending
    entry.order = pedido_1
  end

  FinancialEntry.find_or_create_by!(title: "Venda #{pedido_2.code}") do |entry|
    entry.kind = :income
    entry.category = "Retirada"
    entry.amount = pedido_2.total_amount
    entry.occurred_on = 2.days.ago.to_date
    entry.payment_status = :paid
    entry.order = pedido_2
  end

  FinancialEntry.find_or_create_by!(title: "Compra de cenoura e ovos") do |entry|
    entry.kind = :expense
    entry.category = "Ingredientes"
    entry.amount = 126.40
    entry.occurred_on = Date.current.beginning_of_month + 3.days
    entry.payment_status = :paid
    entry.notes = "Reposicao semanal de ingredientes."
  end

  FinancialEntry.find_or_create_by!(title: "Gas de cozinha") do |entry|
    entry.kind = :expense
    entry.category = "Operacao"
    entry.amount = 115.00
    entry.occurred_on = Date.current.beginning_of_month + 6.days
    entry.payment_status = :paid
  end
end

puts "Seed finalizado com sucesso."
puts "Admins: #{Admin.count} (novos nesta execucao: #{created_admins})"
puts "Categorias: #{Category.count}"
puts "Produtos: #{Product.count} (novos nesta execucao: #{created_products})"
puts "Clientes: #{Customer.count}"
puts "Pedidos: #{Order.count}"
puts "Lancamentos financeiros: #{FinancialEntry.count}"
