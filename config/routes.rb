Rails.application.routes.draw do
  post 'kinesis', to: 'kinesis#create'
end
