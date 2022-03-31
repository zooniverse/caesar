#!/bin/bash

# ensure we stop on error (-e) and log cmds (-x)
set -ex

# Copy commit_id.txt to the public folder or create default
[ -f ./commit_id.txt ] && cp ./commit_id.txt ./public/commit_id.txt || echo "asdf123" > ./public/commit_id.txt

mkdir -p tmp/pids/
rm -f tmp/pids/*.pid

exec bundle exec puma -C config/puma.rb
