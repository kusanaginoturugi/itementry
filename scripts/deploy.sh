#!/usr/bin/env bash
set -euxo pipefail

APP_ROOT="/home/admin/itementry"
cd "$APP_ROOT"

export HOME="/home/admin"
export PATH="/home/admin/.local/share/mise/bin:/home/admin/.local/bin:$PATH"
eval "$(mise activate bash)"
export RAILS_ENV="production"
export BUNDLE_GEMFILE="$APP_ROOT/Gemfile"
export BUNDLE_PATH="$APP_ROOT/vendor/bundle"

git config core.fileMode false

git fetch origin
git pull --ff-only origin main

bundle config set deployment true
bundle config set without 'development test'
bundle install
bin/rails db:migrate
bin/rails assets:precompile

sudo -n /usr/bin/systemctl restart itementry.service
sudo -n /usr/bin/systemctl is-active itementry.service
