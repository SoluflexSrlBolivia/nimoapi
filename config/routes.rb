Rails.application.routes.draw do
  apipie
  root                'static_pages#home'
  get    'help'    => 'static_pages#help'
  get    'about'   => 'static_pages#about'
  get    'contact' => 'static_pages#contact'

  get    'signup'  => 'users#new'
  get    'login'   => 'sessions#new'
  post   'login'   => 'sessions#create'
  delete 'logout'  => 'sessions#destroy'

  resources :users

  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]


  #api
  namespace :api do
    namespace :v1 do
      resources :users, only: [:index, :create, :show, :update, :destroy]
      get "users/:q/search"  => "users#search"
      resources :aliases, only: [:index, :create, :update, :destroy]
      resources :posts, only: [:show, :create, :update, :destroy]
      resources :sessions, only: [:create]
      resources :password_resets,  only: [:create]
      resources :folders, only: [:index, :show, :create, :update, :destroy]
      post "folders/:q/search" => "folders#search"
      resources :groups, only: [:index, :create, :show, :update, :destroy]
      get "groups/:q/search"  => "groups#search"
      get "groups/:id/pictures" => "groups#pictures"
      get "groups/:id/videos" => "groups#videos"
      get "groups/:id/audios" => "groups#audios"
      get "groups/:id/files" => "groups#g_archives"
      resources :archives, only: [:show, :create, :destroy, :update]
      get "archives/:id/download" => "archives#download"
      resources :worldwide_locations, only: [:index, :show]
      resources :home, only: [:index]
      resources :user_groups, only: [:update, :show, :destroy]
      get "user_groups/:id/join" => "user_groups#join"
      get "user_groups/:id/members" => "user_groups#members"
      post "user_groups/:id/add"  => "user_groups#add_members"
      post "user_groups/:id/alias"  => "user_groups#add_alias"
      post "user_groups/:id/keyword" => "user_groups#register_by_keyword"
      resources :notifications, only: [:index, :update]
      resources :downloads, only: [:create, :destroy]
      resources :rate_archives, only: [:create]
      resources :rate_posts, only: [:create]
      resources :post_comments, only: [:create, :show]
      #resources :post_comments, only: [:show, :create, :update, :destroy]
      #get  "post_comments/:id/post"      => "post_comments#comments"
      resources :folder_comments, only: [:show, :create]
      #get  "folder_comments/:id/folder"      => "folder_comments#comments"
      resources :archive_comments, only: [:create, :show]
      #get "archive_comments/:id" => "archive_comments#comments"
      #resources :archive_comments, only: [:show, :create, :update, :destroy]
      #get  "archive_comments/:id/archive"      => "archive_comments#comments"
      resources :devices, only: [:create]
    end
  end

  #get '/:anything', :to => "static_pages#not_found", :constraints => { :anything => /.*/ }
end
