#!/bin/bash -e

/app/docker/start-app.sh

exec bundle exec puma -C config/puma.rb
