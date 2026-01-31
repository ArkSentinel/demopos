class CartsController < ApplicationController
  def checkout
    cart_data = params[:cart]

    ActiveRecord::Base.transaction do
      # Validar stock antes de crear la venta
      cart_data.each do |item|
        product = Product.find(item[:product_id])
        if product.quantity < item[:quantity].to_i
          raise ActiveRecord::Rollback, "Stock insuficiente para #{product.name}"
        end
      end

      # Crear la venta
      # Dentro del bloque de creación de la venta:
      sale = Sale.create!(
        total: cart_data.sum { |item| item[:quantity].to_i * item[:price].to_f },
        user_id: current_user.id # <--- ¡Importante para saber quién vendió!
      )

      # Crear items y descontar stock
      cart_data.each do |item|
        product = Product.find(item[:product_id])

        sale.sale_items.create!(
          product_id: product.id,
          quantity: item[:quantity],
          price: item[:price]
        )

        product.update!(quantity: product.quantity - item[:quantity].to_i)
      end

      render json: { message: "Compra finalizada correctamente", sale_id: sale.id }
    end
  rescue ActiveRecord::Rollback => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue => e
    render json: { error: "Error al procesar la compra: #{e.message}" }, status: :unprocessable_entity
  end
end
