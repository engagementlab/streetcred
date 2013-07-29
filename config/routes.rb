Streetcred::Application.routes.draw do
  root :to => 'users#index' 
  
  resources :campaigns, :only => [:index, :show]
  resources :users, :only => [:index, :show]
  
  devise_for :users, :controllers => {:omniauth_callbacks => "users/omniauth_callbacks", :sessions => 'sessions', :registrations => 'registrations'}
  devise_scope :user do
    get "sign_in", :to => "admin/sessions#new"
    get "sign_out", :to => "admin/sessions#destroy"
    get "edit_registration", :to => "admin/registrations#edit"
  end
  
  devise_for :admin_users, :controllers => {:sessions => 'admin/sessions', :registrations => 'admin/registrations'}
  devise_scope :admin_user do
    get "admin_sign_in", :to => "admin/sessions#new"
    get "admin_sign_out", :to => "admin/sessions#destroy"
    get "edit_admin_registration", :to => "admin/registrations#edit"
  end
  
  namespace :admin do
    root :to => 'campaigns#index'
    match 'campaigns/add_required_action' => 'campaigns#add_required_action', :as => 'add_required_action'
    resources :admin_users, :only => [:index, :show]
    resources :actions, :only => [:index, :show]
    resources :action_types
    resources :campaigns
    resources :channels
    resources :users, :only => [:index, :show]
  end
  
  namespace :api, :defaults => {:format => :json} do
    resources :actions do
      collection do
        post 'email'
        post 'citizens_connect'
        post 'street_bump'
        post 'foursquare'
      end
    end
    resources :action_types
    resources :campaigns
    resources :users
  end
end
