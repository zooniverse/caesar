require 'sidekiq/web'
Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]

require 'panoptes_admin_constraint'

Rails.application.routes.draw do
  if Rails.env.development? || Rails.env.staging?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end

  post "/graphql", to: "graphql#execute"
  mount Sidekiq::Web => '/sidekiq', constraints: PanoptesAdminConstraint.new

  get '/', to: 'status#show'

  resource :session
  get '/auth/:provider/callback', to: 'sessions#create'

  post 'kinesis', to: 'kinesis#create'

  resources :workflows do
    resources :extractors, only: [:new, :create, :edit, :update, :destroy]
    resources :subjects, only: [:index, :show]

    resources :data_requests
  end

  get 'workflows/:workflow_id/extractors/:extractor_key/extracts', to: 'extracts#index'
  put 'workflows/:workflow_id/extractors/:extractor_key/extracts', to: 'extracts#update', defaults: { format: :json }

  get 'workflows/:workflow_id/reducers/:reducer_key/reductions', to: 'reductions#index'
  get 'workflows/:workflow_id/subjects/:subject_id/reductions', to: 'reductions#index'
  put 'workflows/:workflow_id/reducers/:reducer_key/reductions', to: 'reductions#update'
  put 'workflows/:workflow_id/reducers/:reducer_key/reductions/nested', to: 'reductions#nested_update'
end
