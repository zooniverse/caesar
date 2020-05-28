#!/bin/bash

# ensure we stop on error (-e) and log cmds (-x)
set -ex

mkdir -p tmp/pids/
rm -f tmp/pids/*.pid

if [ "$RAILS_ENV" != "development" ]; then
  bin/rails db:migrate
fi

exec bundle exec puma -C config/puma.rb
