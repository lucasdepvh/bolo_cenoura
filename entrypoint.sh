#!/bin/bash
set -e

echo "Running migrations..."
bundle exec rails db:migrate

echo "Starting server..."
exec "$@"