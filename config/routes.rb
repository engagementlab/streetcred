Streetcred::Application.routes.draw do
  root :to => 'users#index' 
  
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
  
  match '/admin' => 'admin/awards#index'
  namespace :admin do
    match 'awards/add_required_action' => 'awards#add_required_action', :as => 'add_required_action'
    resources :admin_users, :only => [:index, :show]
    resources :actions, :only => [:index, :show]
    resources :action_types
    resources :awards
    resources :campaigns
    resources :channels
    resources :levels
    resources :users, :only => [:index, :show]
  end
  
  namespace :api do
    resources :actions do
      collection do
        post 'citizens_connect'
        post 'street_bump'
        post 'foursquare'
      end
    end
    resources :awards
    resources :users
  end

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

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
