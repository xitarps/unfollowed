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
    # The source is bind-mounted, hiding the assets built into the image; Propshaft only serves precompiled assets in production.
    if [ "$RAILS_ENV" = "production" ]; then
      echo ' --> Precompiling assets '
      bin/rails assets:clobber assets:precompile
    else
      # Stale precompiled assets would make Propshaft ignore live changes in development.
      bin/rails assets:clobber
    fi
    ;;
esac

exec "$@"
