def next?
  File.basename(__FILE__) == "Gemfile.next"
end
source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'active_record_extended'
gem 'httparty'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
if next?
  gem 'rails', '7.2.2.1'
else
  gem 'rails', '7.1.5.1'
end
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.3'
# Use Puma as the app server
gem 'puma', '~> 5.6'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
gem 'bootstrap-sass', '~> 3.4.1'
gem 'jquery-rails'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
gem 'bootsnap', '>= 1.1.0', require: false

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
gem 'sidekiq'
gem 'sidekiq-congestion', '~> 0.1.0'
gem 'sidekiq-unique-jobs', '~> 7.1.0'
gem 'sidekiq-logstash'
gem 'panoptes-client', '~> 1.2'
gem 'lograge'
gem 'logstash-event'
gem "sentry-raven"
gem 'omniauth', '~> 2.1'
gem 'omniauth-zooniverse', '~>0.0.5'
gem 'responders'
gem 'listen', '>= 3.0.5', '< 3.8'
gem 'rest-client', '> 2.0'
gem 'jsonpath'
gem 'simple_form'
gem 'pundit', "~> 2.2.0"
gem 'graphql', "1.12.25"
gem 'graphiql-rails'
gem 'stoplight'
gem 'ranked-model'
gem 'deferred_associations'
gem 'aws-sdk-s3'
gem 'aws-sdk-sqs'
gem 'strong_migrations'
gem 'ffi', '< 1.17.0'
# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'

group :production, :staging do
  gem 'newrelic_rpm'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: [:mri, :mingw, :x64_mingw]
  gem 'pry-byebug'
  gem 'rspec-rails'
  gem 'pry-rails'
  gem 'webmock'
  gem 'spring-commands-rspec'
  gem 'rubocop'
  gem 'factory_bot_rails'
  gem 'rails-controller-testing'
  gem 'ten_years_rails'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 3.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
