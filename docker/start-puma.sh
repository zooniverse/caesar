#!/bin/bash -e

/app/docker/start_app.sh

exec bundle exec puma -C config/puma.rb
