PlatoForum::Application.routes.draw do
  # Static Pages
  get "static/about"
  get "static/privacy_policy"
  get "static/contact"
  
  #resources :stances
  #resources :topics
  #resources :comments
  #resources :users
  #resources :proxies

  #get ':topic_id' => "topic#show"
  #get ':topic_id/comments/new' => "comments#new"

  #get ':lastpage/auth/:provider/callback' => 'sessions#create'
  get 'admin' => 'admins#admin'

  get 'admin/edit_user/:id' => 'admins#edit_user'
  patch 'admin/edit_user/:id' => 'admins#update_user'
  get 'admin/kill_user/:id' => 'admins#destroy_user'
  post 'admin/broadcast' => 'admins#broadcast'
  get 'admin/robot' => 'admins#robot'
  get 'admin/de_robot' => 'admins#de_robot'

  get 'user/panel' => 'users#panel'
  get 'user/toggle_show_FB' => 'users#toggle_show_FB'
  get 'user/toggle_list_comments' => 'users#toggle_list_comments'
  get 'user/activities' => 'users#activities'
  get 'user/subscriptions' => "topics#subscriptions"
  get 'user/notifications' => "users#notifications"
  get 'user/notifications/clear' => "users#noti_clear"
  get 'user/notifications/more/:offset' => "users#notifications_more"
  get 'user/achievements' => "users#achievements"
  get 'notification_:id'=> "users#notification"

  get 'auth/:provider/callback' => 'sessions#create'
  get 'auth/failure' => redirect('/')
  get "signin" => "sessions#new", :as => "signin"
  get "signout" => "sessions#destroy", :as => "signout"

  get "like/:id" => "comments#like", as: 'like_comment'
  get "dislike/:id" => "comments#dislike", as: 'dislike_comment'
  get "neutral/:id" => "comments#neutral", as: 'neutral_comment'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'topics#index'
  post 'topics/create' => "topics#create"

  get 'list' => "topics#completelist"

  # FB Notification Binding
  get 'fbcanvas' => "facebook#canvas"
  post 'fbcanvas' => "facebook#canvas"
  post 'fbcanvas/notification/:id' => "facebook#notification"
 
  #get ':permalink/comments/new' => "comments#new"
  post ':permalink/comments' => "comments#create"
  post ':permalink/comment_:id/reply' => "comments#reply"
  post ':permalink/comment_:id/reply_old' => "comments#reply_old"
  get ':permalink/comment_:id/delete' => "comments#destroy"
  
  get ':permalink/comment_:id' => "comments#show"
  get 'comment_:id' => "comments#show"
  get 'comment_:id/reply_:stance' => "comments#show_reply"
  #get 'link_comment_:id' => "comments#show_link"
  get ':permalink/comments/more_stance_:stance/:offset' => "comments#show_more"

  get ':permalink/subscribe' => "topics#subscribe"
  get ':permalink/unsubscribe' => "topics#unsubscribe"

  get ':permalink/edit' => "topics#edit"
  patch ':permalink/edit' => "topics#update"
  delete ':permalink' => "topics#destroy"
  #get ':permalink/change_name' => 'users#change_pseudonym'

  get ':permalink/proxy_real' => "proxies#make_real"
  get ':permalink/proxy_fake' => "proxies#make_fake"

  get ':permalink/stance_:stance/more_importance/:offset' => "stances#show_more_importance"
  get ':permalink/stance_:stance/more_time/:offset' => "stances#show_more_time"
  get ':permalink/stance_:stance' => "stances#show"

  get ':permalink/stances/new' => "stances#new"
  post ':permalink/stances' => "stances#create"
  get ':permalink/stance_:id/edit' => "stances#edit"
  patch ':permalink/stance_:id'=> "stances#update"

  get ':permalink/proxy_:proxy' => "proxies#show"

  get ':permalink/comments' => "topics#show"
  get ':permalink' => "topics#show"

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
