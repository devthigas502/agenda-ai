# frozen_string_literal: true

puts "=== Seeding AgendaAI Demo Data ==="

# 1. Account
account = Account.find_or_create_by!(slug: "barbearia-premium") do |acc|
  acc.name = "Barbearia Premium"
  acc.email = "contato@barbeariapremium.com.br"
  acc.phone = "(11) 98765-4321"
  acc.timezone = "America/Sao_Paulo"
  acc.plan = "starter"
  acc.trial_ends_at = 30.days.from_now
end
puts "Account: #{account.name} (slug: #{account.slug})"

# Set Current Tenant for seeding tenant-scoped models
ActsAsTenant.current_tenant = account

# 2. Owner User
user = User.find_or_initialize_by(email: "admin@barbeariapremium.com.br")
if user.new_record?
  user.account = account
  user.name = "Carlos Eduardo"
  user.password = "senha123"
  user.password_confirmation = "senha123"
  user.role = "owner"
  user.save!
  puts "User: #{user.email} (Password: senha123)"
end

# 3. Professionals
prof_marcos = Professional.find_or_create_by!(name: "Marcos Barbeiro") do |p|
  p.email = "marcos@barbeariapremium.com.br"
  p.phone = "(11) 91111-2222"
  p.bio = "Especialista em cortes clássicos e barba com toalha quente."
  p.active = true
  p.position = 1
end

prof_lucas = Professional.find_or_create_by!(name: "Lucas Stylist") do |p|
  p.email = "lucas@barbeariapremium.com.br"
  p.phone = "(11) 93333-4444"
  p.bio = "Especialista em degradê, freestyle e coloração."
  p.active = true
  p.position = 2
end
puts "Professionals: #{prof_marcos.name}, #{prof_lucas.name}"

# 4. Services
serv_corte = Service.find_or_create_by!(name: "Corte de Cabelo") do |s|
  s.description = "Corte masculino com lavagem e finalização com pomada."
  s.duration_minutes = 30
  s.price_cents = 5000 # R$ 50,00
  s.active = true
  s.position = 1
end

serv_barba = Service.find_or_create_by!(name: "Barba Completa") do |s|
  s.description = "Modelagem de barba com esfoliação e terapia de toalha quente."
  s.duration_minutes = 30
  s.price_cents = 4000 # R$ 40,00
  s.active = true
  s.position = 2
end

serv_combo = Service.find_or_create_by!(name: "Combo Cabelo + Barba") do |s|
  s.description = "Pacote completo de transformação: corte + barba + bebidas do bar."
  s.duration_minutes = 60
  s.price_cents = 8000 # R$ 80,00
  s.active = true
  s.position = 3
end
puts "Services: #{serv_corte.name}, #{serv_barba.name}, #{serv_combo.name}"

# Link Professionals to Services
[serv_corte, serv_barba, serv_combo].each do |service|
  ProfessionalService.find_or_create_by!(professional: prof_marcos, service: service)
  ProfessionalService.find_or_create_by!(professional: prof_lucas, service: service)
end

# 5. Weekly Schedules (Mon-Sat, 09:00 - 19:00)
(1..6).each do |weekday|
  Schedule.find_or_create_by!(professional: prof_marcos, weekday: weekday) do |s|
    s.starts_at = Time.parse("09:00")
    s.ends_at = Time.parse("19:00")
  end

  Schedule.find_or_create_by!(professional: prof_lucas, weekday: weekday) do |s|
    s.starts_at = Time.parse("10:00")
    s.ends_at = Time.parse("20:00")
  end
end
puts "Schedules configured for Marcos and Lucas."

# 6. Sample Client
client = Client.find_or_create_by!(phone: "(11) 99999-8888") do |c|
  c.name = "Gabriel Souza"
  c.email = "gabriel@gmail.com"
end

# 7. Sample Booking for Tomorrow
tomorrow_slot = Date.tomorrow.to_time.change(hour: 14, min: 0)
Booking.find_or_create_by!(starts_at: tomorrow_slot, professional: prof_marcos) do |b|
  b.account = account
  b.service = serv_combo
  b.client = client
  b.ends_at = tomorrow_slot + 60.minutes
  b.status = "confirmed"
  b.price_cents = serv_combo.price_cents
  b.source = "public_page"
end
puts "Sample booking created for tomorrow at 14:00."

puts "=== Seeding Complete ==="
