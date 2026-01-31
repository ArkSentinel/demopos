class Sale < ApplicationRecord
  belongs_to :user   # empleado que realiza la venta
  has_many :sale_items, dependent: :destroy
  has_many :products, through: :sale_items
end
