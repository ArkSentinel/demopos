class InventoryController < ApplicationController
  before_action :authenticate_user! 
  def index
    @products = Product.all

    # filtro por búsqueda (nombre o descripción)
    if params[:q].present?
      query = "%#{params[:q].strip}%"
      @products = @products.where("name LIKE ? OR description LIKE ?", query, query)
    end

    # filtro por categoría
    if params[:category_id].present? && params[:category_id].to_i > 0
      @products = @products.where(category_id: params[:category_id])
    end

    @products = @products.order(updated_at: :desc)
  end

  def authorize_admin! 
    redirect_to root_path, alert: "No autorizado" unless current_user&.admin? 
  end
end
