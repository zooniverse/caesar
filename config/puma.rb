# frozen_string_literal: true

# For more information: https://github.com/puma/puma/blob/master/examples/config.rb
app_path = File.expand_path(File.dirname(File.dirname(__FILE__)))

pidfile "#{app_path}/tmp/pids/server.pid"
state_path "#{app_path}/tmp/pids/puma.state"

environment ENV.fetch('RAILS_ENV', 'development')
port        ENV.fetch('PORT', 3000)

bind "tcp://0.0.0.0:#{port}"

threads_count = ENV.fetch('RAILS_MAX_THREADS', 2).to_i
# === Non-Cluster mode (no worker / forking) ===
threads 1, threads_count

# Additional text to display in process listing
tag 'caesar_app'
