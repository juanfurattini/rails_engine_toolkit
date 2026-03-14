#!/usr/bin/env bash

set -euo pipefail

echo "=========================================="
echo "Rails Engine Toolkit - Local Smoke Test"
echo "=========================================="

SUCCESS=false

echo "🧪 Active Ruby:"
ruby -v
which ruby
bundle -v

ruby -e '
major, minor, = RUBY_VERSION.split(".").map(&:to_i)
ok = (major > 3) || (major == 3 && minor >= 2)
exit(ok ? 0 : 1)
' || {
  echo "❌ Ruby 3.2+ is required to run this smoke test."
  echo "   Current Ruby: $(ruby -v)"
  echo "   Activate a compatible Ruby version with your version manager and try again."
  exit 1
}

# TOOLKIT_PATH="$(pwd)"
# HOST_APP_TMP="/tmp/host_app"

# echo "➡️ Toolkit path: $TOOLKIT_PATH"
# echo "➡️ Host app tmp: $HOST_APP_TMP"

TOOLKIT_PATH="${GITHUB_WORKSPACE:-$(pwd)}"
TMP_ROOT="$TOOLKIT_PATH/tmp"
HOST_APP="$TMP_ROOT/host_app"

cleanup_host_app_dir() {
  if [ "${KEEP_SMOKE_TMP:-false}" != "true" ]; then
    rm -rf "$HOST_APP"
  fi
}

show_script_result() {
  if [ "$SUCCESS" = true ]; then
    echo "=========================================="
    echo "✅ Smoke test completed successfully"
    echo "=========================================="
  else
    echo "❌ Smoke test failed"
  fi
}

cleanup_trap() {
  echo "🧹 Cleaning..."
  cleanup_host_app_dir
  show_script_result
}

trap cleanup_trap EXIT

echo "Preparing tmp workspace..."

echo "Ensuring tmp root exists..."
mkdir -p "$TMP_ROOT"

echo "➡️ Toolkit path: $TOOLKIT_PATH"
echo "➡️ Tmp root: $TMP_ROOT"
echo "➡️ Host app: $HOST_APP"

echo "🧹 Cleaning previous tmp host app..."
cleanup_host_app_dir

echo "📦 Copying fixture host app..."
cp -R test/fixtures/host_app "$HOST_APP"

cd "$HOST_APP"

echo "📍 Now inside: $(pwd)"
echo "🧪 Ruby inside host app:"
ruby -v
which ruby
bundle -v

echo "🔧 Resetting bundler deployment flags..."
bundle config unset frozen || true
bundle config unset deployment || true

echo "🔗 Linking local toolkit gem..."
bundle config set local.rails_engine_toolkit "$TOOLKIT_PATH"

echo "🔧 Setting bundler dev mode..."
bundle config set --local frozen false
bundle config set --local deployment false

echo "📦 Running bundle install..."
bundle install

echo "✅ Checking config file..."
if [ ! -f "config/engine_toolkit.yml" ]; then
  echo "❌ Missing config/engine_toolkit.yml"
  exit 1
fi

echo "🚀 Creating engine auth..."
printf '\n' | bundle exec engine-toolkit new_engine auth

echo "🔎 Validating engine creation..."
if [ ! -d "engines/auth" ]; then
  echo "❌ Engine was not created"
  exit 1
fi

echo "🔎 Validating routes mount..."
if ! grep -q "Auth::Engine" config/routes.rb; then
  echo "❌ Engine mount not found in routes"
  exit 1
fi

echo "🧪 Running additional smoke checks..."

echo "➡️ Generating model..."
bundle exec engine-toolkit new_engine_model auth credential email:string

echo "➡️ Generating migration..."
bundle exec engine-toolkit new_engine_migration auth create_test_table

echo "➡️ Updating README..."
bundle exec engine-toolkit update_engine_readme auth

SUCCESS=true
