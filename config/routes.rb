Rails.application.routes.draw do
  devise_for  :users,
  :path => '',
  :path_names => {
    :sign_in => "login",
    :sign_out => "logout",
    :edit => "personal-setting"
  },
  controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    passwords: 'users/passwords'
  }
  devise_scope :user do
    get "forgot-password" => "users/passwords#new"
    get "reset-password" => "users/passwords#edit"
  end
  get "home/index"
  root to: redirect('/projects')
  resources :users do
    collection do
      get 'render_create', to: 'users#render_create'
    end
    member do
      get 'render_edit', to: 'users#render_edit'
    end
  end
  resources :logs do

  end
  resources :projects do
    collection do
      get 'render_create', to: 'projects#render_create'
      get 'render_user_project_role_create', to: 'projects#render_user_project_role_create'
    end
    member do
      get 'render_edit', to: 'projects#render_edit'
      get 'render_user_project_role_edit', to: 'projects#render_user_project_role_edit'
    end
    resources :prompts do
      collection do
        post 'update_max_tokens', to: 'prompts#update_max_tokens'
        post 'update_api_type', to: 'prompts#update_api_type'
      end
      member do
        post 'run-test'
        patch 'run-test-draft'
        patch 'save-test'
      end
    end
  end

  resources :keys, only: %i[index create destroy], defaults: { format: :js }

  get "download_key/:id", to: 'keys#download', as: 'download_key'
  get "download_log", to: 'logs#download_log', as: 'download_log'

  namespace :api do
    namespace :v1 do
      post 'prompts/:id/:endpoint_name', to: 'prompts#request_ai'
      post 'users/sync', to: 'user#sync_user'
    end
  end

  get '/callback', to: 'users_callback#callback'
  get '/callback_complete', to: 'users_callback#login_complete'
  post 'language', to: 'language#change'

  get 'playground/:prompt_id', to: 'playground#index', as: 'Local_playground'
  post 'playground/update_api_type', to: 'playground#update_api_type'
  post 'playground/update_max_tokens', to: 'playground#update_max_tokens'
  post 'playground/run_test', to: 'playground#run_test'
  post 'new_playground', to: 'playground#new_playground'
  post 'update_playground', to: 'playground#update_playground'
  post 'delete_playground', to: 'playground#delete_playground'

  get 'chat/:token', to: 'chat#chat', as: 'Local_id_chat'
  post '/new_chat', to: 'chat#new_chat'
  post '/chat_gpt', to: 'chat#chat_gpt'
  post '/update_chat', to: 'chat#update_chat'
  post '/delete_chat', to: 'chat#delete_chat'
  get '/chat_history', to: 'chat#chat_history'
  get '/download_csv/:token', to: 'chat#download_csv', as: 'download_chat'
  post '/update_model', to: 'chat#update_model'

  match  '404', to: 'errors#errors_404', via: :all
  match  '500', to: 'errors#errors_500', via: :all
  match  '403', to: 'errors#errors_403', via: :all
  get '*path', to: 'errors#errors_404'
end
