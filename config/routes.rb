FamilyTreeAnalyzer::Application.routes.draw do
  # match '/', to: 'static_pages#home', via: 'get'
  root 'static_pages#home'
  post '/rename_gedcom_file' => 'static_pages#rename'
  get '/filters/:id' => 'filters#index', as: :filter
  get '/filters/:id/persons_not_for_analysis' => 'filters#ajax_persons_not_for_analysis', as: :filter_persons_not_for_analysis
  get '/filters/:id/persons_for_analysis' => 'filters#ajax_persons_for_analysis', as: :filter_persons_for_analysis
  get '/filters/:id/all_persons' => 'filters#ajax_all_persons', as: :filter_all_persons
  post '/filters/:id' => 'filters#update'
  get '/analysis/:id' => 'analyses#analysis', as: :analysis
  post '/upload' => 'static_pages#upload'
  ### dummy route
  #get '/analysis' => 'analyses#analysis'
  
  delete '/gedcom_file/:id' => 'gedcom_files#delete', as: :gedcom_file
  get '/gedcom_file/:id' => 'gedcom_files#go_to_analysis'

  get '/select_tree' => 'static_pages#select_tree'

  authenticated :user, lambda { |user| user.admin? } do
    get '/admin' => 'admin#index'
    get '/admin/gedcom_files_archive' => 'admin#gedcom_files_archive'
    get '/admin/download_gedcom/:id' => 'admin#download_gedcom_file', as: :download_gedcom_file
    delete '/admin/gedcom/delete/:id' => 'admin#delete_gedcom_file', as: :delete_gedcom_file
  end

  devise_scope :user do
    get '/reset_password' => "passwordusers#new", :as => :reset_password
    get '/new_password' => "passwordusers#edit", :as => :new_password
    post '/send_email' => 'passwordusers#create', :as => :create_password
    put '/change' =>  'passwordusers#update', :as => :update_password
  end

  devise_for :users

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

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
