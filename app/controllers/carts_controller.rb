class CartsController < ApplicationController
  def checkout
    cart_data = params[:cart]

    if cart_data.blank?
      return render json: { error: "El carrito está vacío" }, status: :unprocessable_entity
    end

    ActiveRecord::Base.transaction do
      # 1. Validar stock de todos los productos antes de hacer nada
      cart_data.each do |item|
        product = Product.find(item[:product_id])
        if product.quantity < item[:quantity].to_i
          raise "Stock insuficiente para #{product.name}" 
        end
      end

      # 2. Crear la venta (Asociada al usuario logueado)
      # Nota: Usamos create! (con signo !) para que si algo falla, salte al rescue
      sale = Sale.create!(
        total: cart_data.sum { |item| item[:quantity].to_i * item[:price].to_f },
        user: current_user
      )

      # 3. Crear los detalles de la venta y descontar stock
      cart_data.each do |item|
        product = Product.find(item[:product_id])
        
        sale.sale_items.create!(
          product: product,
          quantity: item[:quantity],
          price: item[:price]
        )

        # Descontamos del inventario
        product.update!(quantity: product.quantity - item[:quantity].to_i)
      end

      # 4. Limpiar sesión si usas carrito de servidor
      session[:cart] = [] 

      # 5. Respuesta de éxito (dentro de la transacción)
      render json: { message: "Venta exitosa", sale_id: sale.id }, status: :ok
    end

  rescue => e
    # Si algo falla (stock, base de datos, etc.), se cancela todo y enviamos el error
    render json: { error: e.message }, status: :unprocessable_entity
  end
end