PlatoForum::Application.routes.draw do
  # Static Pages
  get "static/about"
  get "static/privacy_policy"
  get "static/contact"
  
  resources :stances

  resources :topics

  resources :comments

  resources :users

  resources :proxies

  #get ':topic_id' => "topic#show"
  #get ':topic_id/comments/new' => "comments#new"

  #get ':lastpage/auth/:provider/callback' => 'sessions#create'

  get 'user/panel' => 'users#panel'
  get 'user/activities' => 'users#activities'
  get 'user/subscriptions' => "topics#subscriptions"
  get 'user/notifications' => "users#notifications"
  get 'notifications_:id'=> "users#notification"

  get 'auth/:provider/callback' => 'sessions#create'
  get 'auth/failure' => redirect('/')
  get "signin" => "sessions#new", :as => "signin"
  get "signout" => "sessions#destroy", :as => "signout"

  put "like/:id" => "comments#like", as: 'like_comment'
  put "dislike/:id" => "comments#dislike", as: 'dislike_comment'
  put "neutral/:id" => "comments#neutral", as: 'neutral_comment'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'topics#index'

  get 'list' => "topics#completelist"
 
  #get ':permalink/comments/new' => "comments#new"
  post ':permalink/comments' => "comments#create"
  post ':permalink/comment_:id/reply' => "comments#reply"
  
  get ':permalink/comment_:id' => "comments#show"

  get ':permalink/subscribe' => "topics#subscribe"
  get ':permalink/unsubscribe' => "topics#unsubscribe"

  get ':permalink/edit' => "topics#edit"
  #get ':permalink/change_name' => 'users#change_pseudonym'

  get ':permalink/proxy_real' => "proxies#make_real"
  get ':permalink/proxy_fake' => "proxies#make_fake"

  get ':permalink/stance_:stance' => "stances#show"
  get ':permalink/proxy_:proxy' => "proxies#show"

  get ':permalink' => "comments#index"

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
