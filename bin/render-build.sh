#!/usr/bin/env bash
set -e

bundle install
SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile
bundle exec rails assets:clean
