# Limpiar usuarios previos para evitar errores de duplicación
puts "Limpiando base de datos..."
User.destroy_all

puts "Creando usuarios..."

# 1. El Administrador
admin = User.create!(
  email: 'admin@pos.com',
  password: 'password123',
  password_confirmation: 'password123',
  role: 'admin'
)
puts "Admin creado: admin@pos.com"

# 2. El Empleado
employee = User.create!(
  email: 'empleado@pos.com',
  password: 'password123',
  password_confirmation: 'password123',
  role: 'employee'
)
puts "Empleado creado: empleado@pos.com"

puts "--- Proceso de Seeds finalizado ---"