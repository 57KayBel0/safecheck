#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
server_dir=$(dirname -- "$script_dir")
flutter_dir=$(CDPATH= cd -- "$server_dir/../safecheck_flutter" && pwd)
output_dir="$server_dir/web/app"

client_id=${SAFE_CHECK_GOOGLE_CLIENT_ID:-}
web_origin=${SAFE_CHECK_WEB_ORIGIN:-https://safecheck.serverpod.space}
redirect_uri=

  case "$web_origin" in
    https://*) ;;
    *) echo 'SAFE_CHECK_WEB_ORIGIN must be an HTTPS origin.' >&2; exit 1 ;;
  esac
  authority=${web_origin#https://}
  case "$authority" in
    ''|localhost|localhost:*|*.localhost|*.localhost:*|127.*|\[::1\]*|*/*|*\?*|*\#*|*@*)
      echo 'SAFE_CHECK_WEB_ORIGIN must be an HTTPS origin without a path or trailing slash.' >&2
      exit 1
      ;;
  esac
  redirect_uri="$web_origin/auth.html"

set -- web --release --base-href /
set -- "$@" "--dart-define=GOOGLE_CLIENT_ID=$client_id"
# Runtime public metadata decides readiness; no credential enters this build.
set -- "$@" "--dart-define=GOOGLE_WEB_REDIRECT_URI=$redirect_uri"

cd "$flutter_dir"
flutter build "$@"
test -f "$flutter_dir/build/web/auth.html" || {
  echo 'Flutter web build did not produce auth.html; refusing to package an incomplete callback route.' >&2
  exit 1
}

case "$output_dir" in
  "$server_dir/web/app") ;;
  *) echo 'Refusing to copy the Flutter build outside safecheck_server/web/app.' >&2; exit 1 ;;
esac
rm -rf "$output_dir"
mkdir -p "$output_dir"
cp -R "$flutter_dir/build/web/." "$output_dir/"
