class CartController < ApplicationController
  def show
    @products = Product.where(id: session[:cart] || [])
  end

  def add
    session[:cart] ||= []
    session[:cart] << params[:product_id]
    redirect_to cart_path, notice: "Producto agregado"
  end

  def checkout
  @products = Product.where(id: session[:cart] || [])
  @sale = Sale.create!(
    user: current_user, # aquí se asocia el empleado logueado
    client_rut: params[:rut],
    pickup_time: params[:pickup_time],
    total: @products.sum(&:price)
  )
  session[:cart] = []
  redirect_to receipt_sale_path(@sale)
end

end
