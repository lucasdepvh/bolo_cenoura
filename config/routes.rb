Rails.application.routes.draw do
  devise_for :admins, skip: [:registrations], path: '', path_names: { sign_in: 'iniciar-sessao', sign_out: 'sair' }

  namespace :admin, path: 'administracao' do 
    root "home#index"
    resource :profile, only: [:edit, :update], path: 'perfil'
    resources :categories, path: 'categorias'
    resources :products, path: 'produtos'
    resources :customers, path: 'clientes', only: [:index, :show]
    resources :orders, path: 'pedidos', only: [:index, :show, :update]
    resources :financial_entries, path: 'financeiro'
  end

  root "home#index"
  resources :products, path: 'produtos', only: [:show]
  resources :orders, path: 'pedidos', only: [:create]

  get 'quem-somos', to: 'home#who_we_are', as: 'who_we_are'

  get '/produtos/imagens/:id', to: 'application#product_image_show', as: 'product_image_show'
end
