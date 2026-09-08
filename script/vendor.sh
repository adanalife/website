#!/usr/bin/env bash
# Sync / verify the vendored frontend assets in source/assets, against the
# releases pinned in that directory's vendor.txt.
#
#   vendor.sh sync     re-download every asset at its pinned version
#   vendor.sh check    fail if a file on disk is no longer byte-identical to its
#                      pinned upstream (an in-place edit, or an upstream
#                      re-publish) -- needs only curl and cmp
#   vendor.sh latest   report assets whose tracked dist-tag has moved past the
#                      pinned version -- needs jq, never fails
#
# check and latest are separate because their verdicts are: a byte difference
# wants a human before merge, while a new upstream release is news. A daily red
# check for "htmx cut a release" is a check you learn to ignore.
set -euo pipefail

cd "$(dirname "$0")/.."
readonly dir=source/assets
readonly list="$dir/vendor.txt"

# Comments and blank lines out; the remaining columns are whitespace-separated.
assets() { grep -Ev '^[[:space:]]*(#|$)' "$list"; }

# Every asset is fetched before check exits, so one `sync` fixes everything the
# log reports rather than one round-trip per file.
sync() {
  while read -r path _pkg _tag version url; do
    curl -fsSL "${url//\{v\}/$version}" -o "$dir/$path"
    echo "synced  $path @ $version"
  done < <(assets)
}

check() {
  local tmp fail=0
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN

  while read -r path pkg _tag version url; do
    curl -fsSL "${url//\{v\}/$version}" -o "$tmp/upstream"
    if cmp -s "$tmp/upstream" "$dir/$path"; then
      echo "ok      $path @ $version"
    else
      echo "DRIFT   $path is not $pkg@$version -- run 'task vendor:sync'" >&2
      fail=1
    fi
  done < <(assets)

  return "$fail"
}

latest() {
  local newest
  while read -r path pkg tag version _url; do
    newest="$(curl -fsSL "https://registry.npmjs.org/$pkg" |
      jq -r --arg t "$tag" '."dist-tags"[$t] // "unknown"')"
    if [ "$newest" = "$version" ]; then
      echo "current $path @ $version"
    else
      echo "NEW     $path pinned $version, $pkg@$tag is now $newest"
    fi
  done < <(assets)
}

case "${1:-}" in
  sync | check | latest) "$1" ;;
  *)
    echo "usage: $0 {sync|check|latest}" >&2
    exit 2
    ;;
esac
