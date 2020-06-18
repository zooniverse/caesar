#!/bin/bash

# ensure we stop on error (-e) and log cmds (-x)
set -ex

mkdir -p tmp/pids/
rm -f tmp/pids/*.pid

# allow the sidekiq args to come via the env variables
# and is needed for overriding sidekiq config file i.e. for custom tess queue processing
CLI_ARGS=${SIDEKIQ_ARGS:-''}
exec bundle exec sidekiq $CLI_ARGS
