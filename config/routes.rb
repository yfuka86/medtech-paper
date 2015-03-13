Rails.application.routes.draw do
  use_doorkeeper
  devise_for :users, controllers: {
    sessions: "users/sessions",
    confirmations: "users/confirmations",
    passwords: "users/passwords",
    registrations: "users/registrations",
    unlocks: "users/unlocks"
  }

  root 'home#index'

  resources :papers, only: [:index] do
    collection do
      get 'search'
    end
  end

  resources :paper_lists do
    collection do
      get 'shared_new'
      get 'search'
      put 'add_paper'
    end

    member do
      delete 'remove_paper'
    end
  end

  # APIs
  namespace :api do
    scope 'p', module: 'private' do
      resources :paper_lists, only: [] do
        collection do
          put 'add_paper'
          delete 'remove_paper'
        end
      end
    end
  end

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
