class ProductsController < ApplicationController
  before_action :set_product, only: %i[ show edit update destroy ]
  before_action :authenticate_user! 

  # GET /products or /products.json
  def index
    @products = Product.all

    # Filtros (Sincronizados con los nombres de tu vista)
    @products = @products.where("name LIKE ?", "%#{params[:q]}%") if params[:q].present?
    @products = @products.where(category_id: params[:category_id]) if params[:category_id].present?

    # Orden
    if params[:order] == "price_asc"
      @products = @products.order(price: :asc)
    elsif params[:order] == "price_desc"
      @products = @products.order(price: :desc)
    else
      @products = @products.order(created_at: :desc)
    end

    # Paginación (Aumentado a 8 para que rinda más con 4 columnas)
    @products = @products.page(params[:page]).per(8)
  end

  # GET /products/1 or /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # POST /products or /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to inventory_index_path, notice: "Producto creado con éxito." }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1 or /products/1.json
 def update
  # 1. Extraemos la foto de los parámetros para procesarla aparte
    photo = params[:product].delete(:photo)

    respond_to do |format|
      # 2. Actualizamos el producto SIN la foto primero
      if @product.update(product_params.except(:photo))
        
        # 3. Si hay una foto, la adjuntamos DESPUÉS de cerrar la actualización del producto
        if photo.present?
          begin
            @product.photo.attach(photo)
          rescue SQLite3::BusyException
            # Si falla por bloqueo, esperamos un poco y reintentamos una sola vez
            sleep 1
            @product.photo.attach(photo)
          end
        end

        format.html { redirect_to @product, notice: "Producto actualizado correctamente." }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1 or /products/1.json
  def destroy
    @product.destroy!

    respond_to do |format|
      format.html { redirect_to inventory_index_path, notice: "Producto eliminado.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  # SEGURIDAD DE PARÁMETROS: Control de Admin e Imágenes
  def product_params
    # Permitimos :photo (singular) que es como está en tu modelo
    allowed = [:name, :description, :quantity, :category_id, :photo]
    allowed << :price if current_user.role == 'admin'
    
    params.require(:product).permit(allowed)
  end


end