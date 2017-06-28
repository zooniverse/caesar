require 'sidekiq/web'
Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]

require 'panoptes_admin_constraint'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq', constraints: PanoptesAdminConstraint.new

  get '/', to: 'status#show'

  resource :session
  get '/auth/:provider/callback', to: 'sessions#create'

  post 'kinesis', to: 'kinesis#create'

  resources :workflows do
    resources :subjects, only: [:show]
  end

  get 'workflows/:workflow_id/extractors/:extractor_id/extracts', to: 'extracts#index'
  put 'workflows/:workflow_id/extractors/:extractor_id/extracts', to: 'extracts#update'

  get 'workflows/:workflow_id/reducers/:reducer_id/reductions', to: 'reductions#index'
  put 'workflows/:workflow_id/reducers/:reducer_id/reductions', to: 'reductions#update'
end
