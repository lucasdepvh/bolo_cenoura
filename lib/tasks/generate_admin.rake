namespace :db do

desc "Create admin user"
    task :generate_admin => :environment do
        Admin.create(email: 'lucas@gmail.com', password: 'admin123', password_confirmation: 'admin123')
        Admin.create(email: 'lu@gmail.com', password: 'admin123', password_confirmation: 'admin123')
        Admin.create(email: 'ro@gmail.com', password: 'admin123', password_confirmation: 'admin123')
    end
end