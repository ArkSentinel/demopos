Rails.application.routes.draw do
  devise_for :users
  root "products#index"

  resources :products do
    collection do
      post :create_multiple
    end
  end

  resources :categories do
    collection do
      post :create_multiple
    end
  end

  resources :sales do
    member do
      get :receipt
    end
  end

  # Carrito
  resource :cart, only: [:show] do
    post :add, on: :collection
    post :checkout, on: :collection
  end

  # Inventario
  resources :inventory, only: [:index]
end
