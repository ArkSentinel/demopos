class Product < ApplicationRecord
  has_one_attached :photo
  belongs_to :category
  has_many :sale_items 
  has_many :sales, through: :sale_items
end
