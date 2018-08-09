require 'sidekiq/web'
Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]

require 'panoptes_admin_constraint'

Rails.application.routes.draw do
  post "/graphql", to: "graphql#execute"
  mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"

  mount Sidekiq::Web => '/sidekiq', constraints: PanoptesAdminConstraint.new

  get '/', to: 'status#show'

  resource :session
  get '/auth/:provider/callback', to: 'sessions#create'

  post 'kinesis', to: 'kinesis#create'

  resources :workflows do
    resources :extractors
    resources :extractors, param: :key do
      resource :extracts
      resources :extracts, only: [:index]
    end

    resources :reducers
    resources :subject_reductions, param: :reducer_key
    resources :user_reductions, param: :reducer_key

    resources :subject_rules do
      resources :subject_rule_effects
    end

    resources :user_rules do
      resources :user_rule_effects
    end

    resources :subjects, only: [:show] do
      resources :subject_reductions, only: [:index]
    end

    resources :users, only: [:show] do
      resources :user_reductions, only: [:index]
    end

    resources :data_requests
  end

  resources :projects do
    resources :reducers
    resources :subject_reductions, param: :reducer_key
    resources :user_reductions, param: :reducer_key

    resources :subjects, only: [:show] do
      resources :subject_reductions, only: [:index]
    end

    resources :users, only: [:show] do
      resources :user_reductions, only: [:index]
    end
    resources :data_requests
  end
end
