#!/bin/bash
set -e
echo "Running migrations..."
bundle exec rails db:migrate
echo "Starting server..."
exec bundle exec puma -C config/puma.rb -b tcp://0.0.0.0:${PORT:-3000}