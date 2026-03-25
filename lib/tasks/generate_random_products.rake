namespace :db do
    desc "Create 10 random products"

    task :generate_random_products => :environment do
        category = Category.first_or_create(description: "Descrição 00")

        1.upto(30) do |index|
            product = Product.new(
                title: "Product #{index.to_s.rjust(2, '0')}", 
                description: "", 
                price: Random.rand(20.01...299.99).round(2), 
                category_id: category.id
            )

            product.save
        end    
    end
  end