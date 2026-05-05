#!/bin/bash
set -e
echo "=== INICIANDO ==="
echo "PORT: ${PORT}"
echo "RAILS_ENV: ${RAILS_ENV}"
echo "Running migrations..."
bundle exec rails db:migrate 2>&1
echo "=== MIGRATIONS OK ==="
echo "Starting server..."
exec bundle exec puma -C config/puma.rb -b tcp://0.0.0.0:${PORT:-3000} 2>&1
