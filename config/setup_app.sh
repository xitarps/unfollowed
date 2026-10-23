#! /bin/sh

set -e

bundle check || bundle install --jobs 5 --retry 5

if [ -f tmp/pids/server.pid ]; then
  rm -f tmp/pids/server.pid
fi

# Only the web container prepares the database, avoiding a race with the worker.
case "$*" in
  *"rails s"*)
    echo ' --> Preparing database '
    bin/rails db:prepare
    ;;
esac

exec "$@"
