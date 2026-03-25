namespace :db do
    desc "Create 10 random categories"

    task :generate_random_categories => :environment do
        1.upto(12) do |index|
            Category.new(description: "Description #{index.to_s.rjust(2, '0')}").save
        end    
    end
  end