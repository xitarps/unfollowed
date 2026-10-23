#! /bin/sh

set -e

bundle check || bundle install --jobs 5 --retry 5

if [ -f tmp/pids/server.pid ]; then
  rm -f tmp/pids/server.pid
fi

if [ "${RAILS_ENV:-development}" != "development" ]; then
  echo ' --> Running migrations '
  bin/rails db:migrate
  echo ' --> End of migrations '
else
  echo ' --> Skip migrations for Dev env'
fi

exec "$@"
