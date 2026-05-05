#!/usr/bin/env bash
set -e

bundle install
RAILS_ENV=production SECRET_KEY_BASE=1 bundle exec rails assets:precompile
bundle exec rails assets:clean
