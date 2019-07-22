#!/bin/bash

# ensure we stop on error (-e) and log cmds (-x)
set -ex

/app/docker/start-app.sh

exec bundle exec sidekiq
