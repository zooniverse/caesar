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
    resources :reducers
    resources :subjects, only: [:show]

    resources :data_requests
  end

  get 'workflows/:workflow_id/extractors/:extractor_key/extracts', to: 'extracts#index'
  put 'workflows/:workflow_id/extractors/:extractor_key/extracts', to: 'extracts#update', defaults: { format: :json }

  # legacy routes
  get 'workflows/:workflow_id/reducers/:reducer_key/reductions', to: 'subject_reductions#index'
  get 'workflows/:workflow_id/subjects/:subject_id/reductions', to: 'subject_reductions#index'
  put 'workflows/:workflow_id/reducers/:reducer_key/reductions', to: 'subject_reductions#update'

  get 'workflows/:workflow_id/subject_reductions/:reducer_key/reductions', to: 'subject_reductions#index'
  get 'workflows/:workflow_id/subjects/:subject_id/reductions', to: 'subject_reductions#index'
  put 'workflows/:workflow_id/subject_reductions/:reducer_key/reductions', to: 'subject_reductions#update'

  get 'workflows/:workflow_id/user_reductions/:reducer_key/reductions', to: 'user_reductions#index'
  get 'workflows/:workflow_id/users/:user_id/reductions', to: 'user_reductions#index'
  put 'workflows/:workflow_id/user_reductions/:reducer_key/reductions', to: 'user_reductions#update'
end
