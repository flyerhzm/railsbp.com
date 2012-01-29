RailsbpCom::Application.routes.draw do
  post '/' => 'repositories#sync'
  post '/sync_proxy' => 'repositories#sync_proxy'
  root :to => "home#index"
  devise_for :users, :controllers => { :sessions => "users/sessions", :registrations => "users/registrations", :omniauth_callbacks => "users/omniauth_callbacks" } do
    get 'sign_in', :to => 'users/sessions#new', :as => :new_user_session
    get 'sign_out', :to => 'users/sessions#destroy', :as => :destroy_user_session
    put 'update_credit_card', :to => 'users/registrations#update_credit_card', :as => :update_credit_card
    put 'update_plan', :to => 'users/registrations#update_plan', :as => :update_plan
  end
  resources :repositories do
    resources :builds
    resource :configs do
      collection do
        put :sync
      end
    end
    resources :collaborators do
      collection do
        put :sync
      end
    end
  end
  resources :plans
  resources :contacts

  post "stripe" => "stripe#handle"

  match 'page/:name' => 'pages#show', :as => :page

  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
