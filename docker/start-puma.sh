#!/bin/bash -e

if [ -d "/rails_conf/" ]
then
    ln -sf /rails_conf/* ./config/
fi

mkdir -p tmp/pids/
rm -f tmp/pids/*.pid

if [ "$RAILS_ENV" != "development" ]; then
  USER_DATA=$(curl --fail http://169.254.169.254/latest/user-data || echo "")

  # Links static assets for nginx webserver
  ln -s public/ /static-assets

  if [ "$USER_DATA" == "EMERGENCY_MODE" ]
  then
    git pull
  fi

  if [ -f /run/secrets/environment ]
  then
      source /run/secrets/environment
  fi

  bin/rails db:migrate

  if [ -f "commit_id.txt" ]
  then
    cp commit_id.txt public/
  fi
fi

exec bundle exec puma -C config/puma.rb
