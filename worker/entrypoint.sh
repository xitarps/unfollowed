#! /bin/bash
set -e

# Use SIDEKIQ_CONCURRENCY from env (default 3)
SIDEKIQ_CONCURRENCY=${SIDEKIQ_CONCURRENCY:-3}

exec bundle exec sidekiq -c "$SIDEKIQ_CONCURRENCY"
