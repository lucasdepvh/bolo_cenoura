#!/usr/bin/env bash
set -e

bundle exec rails db:prepare

if [ "${RUN_SEEDS_ON_DEPLOY}" = "true" ]; then
  bundle exec rails db:seed
fi
