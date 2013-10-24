WorkoutIos::Application.routes.draw do
  resources :products
  root :to => 'products#index'
  devise_for(:users, :controllers => { :sessions => "sessions",
  :registrations => "registrations"})

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  match 'api/exercise_categories/index' => 'exercise_category#index', :as => :exercise_categories
  match 'api/exercise/create' => 'exercise#create', :as => :create_exercise
  match 'api/user/exercises' => 'user#exercises', :as => :user_exercises
  match 'api/user/exercise_sets' => 'user#exercise_sets', :as => :user_exercise_sets
  match 'api/user/exercise_sets/delete' => 'user#delete_exercise_set' , :as => :user_delete_exercise_set
  match 'api/user/exercise_set/batch_update' => 'user#batch_update_exercise_set' , :as => :user_batch_update_exercise_set
  match 'api/user/save_routine' => 'user#save_routine' , :as => :user_save_routine

  match 'api/routines' => 'routine#index', :as => :routines
  match 'api/routine' => 'routine#get', :as => :routine
  match 'api/routine/complete_exercise' => 'routine#complete_exercise', :as => :routine_complete_exercise
  match 'api/routine/complete_routine' => 'routine#complete_routine', :as => :routine_complete_routine
  match 'api/routine/start' => 'routine#start', :as => :routine_start

  match 'api/routine_session/new' => 'routine_session#new', :as => :new_routine_session
  match 'api/exercise_set/create' => 'exercise_set#create', :as => :create_exercise_set
  match 'api/exercise_set/get' => 'exercise_set#get', :as => :get_exercise_set

  match 'api/exercise/search' => 'exercise#search', :as => :search_exercises
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
  # match ':controller(/:action(/:id))(.:format)'
end
