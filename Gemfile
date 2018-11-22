source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.4'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'
# Use Puma as the app server
gem 'puma', '~> 3.12'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
gem 'bootstrap-sass', '~> 3.3.6'
gem 'jquery-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
gem 'sidekiq'
gem 'sidekiq-congestion', '~> 0.1.0'
gem 'sidekiq-unique-jobs'
gem 'sidekiq-logstash'
gem 'flipper'
gem 'flipper-active_record'
gem 'flipper-ui'
gem 'panoptes-client', '~> 0.3.8'
gem 'newrelic_rpm'
gem 'lograge'
gem 'logstash-event'
gem 'rollbar'
gem 'omniauth'
gem 'omniauth-zooniverse'
gem 'responders'
gem 'listen', '>= 3.0.5', '< 3.2'
gem 'rest-client', '> 2.0'
gem 'jsonpath'
gem 'simple_form'
gem 'pundit', "~> 2.0.0"
gem 'graphql'
gem 'graphiql-rails'
gem 'stoplight'
gem 'dotenv-rails'
gem 'ranked-model'
gem 'deferred_associations'
gem 'aws-sdk-s3'
gem 'aws-sdk-sqs'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: [:mri, :mingw, :x64_mingw]
  gem 'pry-byebug'
  gem 'capybara', '~> 3.11'
  gem 'selenium-webdriver'
  gem 'rspec-rails', '~> 3.8'
  gem 'pry-rails'
  gem 'webmock'
  gem 'spring-commands-rspec'
  gem 'rubocop'
  gem 'factory_girl_rails'
  gem 'rails-controller-testing'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
