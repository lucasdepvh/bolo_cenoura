puts "Iniciando seed..."

admin_email = ENV.fetch("SEED_ADMIN_EMAIL", "admin@gmail.com")
admin_password = ENV.fetch("SEED_ADMIN_PASSWORD", "bolo@cenoura")

admin_accounts = [
  { email: admin_email, password: admin_password },
  { email: "admin@gmail.com", password: "bolo@cenoura" }
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


puts "Seed finalizado com sucesso."
