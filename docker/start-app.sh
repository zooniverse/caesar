#!/bin/bash

# ensure we stop on error (-e) and log cmds (-x)
set -ex

mkdir -p tmp/pids/
rm -f tmp/pids/*.pid

if [ "$RAILS_ENV" != "development" ]; then
  USER_DATA=$(curl --fail http://169.254.169.254/latest/user-data || echo "")

  if [ "$USER_DATA" == "EMERGENCY_MODE" ]
  then
    git pull
  fi

  bin/rails db:migrate

  if [ -f "commit_id.txt" ]
  then
    cp commit_id.txt public/
  fi
fi
