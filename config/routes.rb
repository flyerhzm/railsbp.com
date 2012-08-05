RailsbpCom::Application.routes.draw do
  post '/' => 'repositories#sync'
  post '/sync_proxy' => 'repositories#sync_proxy'
  root :to => "home#index"
  devise_for :users, :controllers => { :sessions => "users/sessions", :registrations => "users/registrations", :omniauth_callbacks => "users/omniauth_callbacks" }
  devise_scope :users do
    get 'sign_in', :to => 'users/sessions#new', :as => :new_user_session
    get 'sign_out', :to => 'users/sessions#destroy', :as => :destroy_user_session
  end
  resources :repositories, only: [:show, :new, :create, :edit, :update] do
    resources :builds, only: [:show, :index]
    resource :configs, only: [:edit, :update] do
      collection do
        put :sync
      end
    end
    resources :collaborators, only: [:create, :destroy, :index] do
      collection do
        put :sync
      end
    end
  end
  resources :contacts, only: [:new, :create]
  resources :plans, only: :index

  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  match ':controller/:action' => '#index', :as => :auto_complete, :constraints => { :action => /auto_complete_for_\S+/ }, :via => :get
end
