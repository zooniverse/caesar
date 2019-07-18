#!/bin/bash -e

./start_app.sh

exec bundle exec sidekiq
