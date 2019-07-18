#!/bin/bash -e

./start_app.sh

exec bundle exec puma -C config/puma.rb
