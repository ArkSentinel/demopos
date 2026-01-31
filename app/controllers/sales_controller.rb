class SalesController < ApplicationController
  before_action :set_sale, only: [:show, :edit, :update, :destroy, :receipt]
  before_action :authenticate_user!, except: [:receipt]
  # GET /sales
  def index
    @sales = Sale.all

    # filtro por búsqueda (ID o total)
    if params[:q].present?
      query = params[:q].strip
      @sales = @sales.where("CAST(id AS TEXT) LIKE ? OR CAST(total AS TEXT) LIKE ?", "%#{query}%", "%#{query}%")
    end

    # filtro por categoría (si tu modelo Sale tiene relación con Category a través de sale_items)
    if params[:category_id].present?
      @sales = @sales.joins(sale_items: :product).where(products: { category_id: params[:category_id] })
    end

    @sales = @sales.order(created_at: :desc)
  end

  # GET /sales/:id
  def show
    render :receipt
  end

  # GET /sales/new
  def new
    @sale = Sale.new
  end

  # POST /sales
  def create
    @sale = Sale.new(sale_params)

    if @sale.save
      redirect_to @sale, notice: "Venta creada correctamente."
    else
      render :new
    end
  end

  # GET /sales/:id/edit
  def edit
  end

  # PATCH/PUT /sales/:id
  def update
    if @sale.update(sale_params)
      redirect_to @sale, notice: "Venta actualizada correctamente."
    else
      render :edit
    end
  end

  # DELETE /sales/:id
  def destroy
    @sale.destroy
    redirect_to sales_url, notice: "Venta eliminada."
  end

  # GET /sales/:id/receipt

  def receipt
    @sale = Sale.find(params[:id])
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "boleta", template: "sales/receipt"
      end
    end
  end


  private

  def set_sale
    @sale = Sale.find(params[:id])
  end

  def sale_params
    params.require(:sale).permit(:total, sale_items_attributes: [:product_id, :quantity, :price])
  end
end
