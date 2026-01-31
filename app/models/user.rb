class User < ApplicationRecord
  # Devise ya está incluido si lo instalaste
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :sales
  # Roles simples
  ROLES = %w[admin employee]


  def admin?
    role == "admin"
  end

  def employee?
    role == "employee"
  end
end
