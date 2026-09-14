#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
out="config-versioned"
mkdir -p "$out"

copy_redacted() {
  src="$1"; dst="$2"
  mkdir -p "$(dirname "$dst")"
  sed -E \
    -e 's#(<ApiKey>)[^<]*(</ApiKey>)#\1<REDACTED>\2#Ig' \
    -e 's#(^[[:space:]]*(api_key|http_password|http_hash_password|http_hashed_password|pms_token|jwt_secret|jwt_update_secret|themoviedb_apikey)[[:space:]]*=[[:space:]]*).*$#\1<REDACTED>#Ig' \
    -e 's#(WebUI\\Password_PBKDF2=).*$#\1<REDACTED>#Ig' \
    -e 's/(apiKey["=: ]+)[^, <"]+/\1<REDACTED>/Ig' \
    -e 's/(password|passkey|token|secret|claim)["=: ]+[^, <"]+/\1=<REDACTED>/Ig' \
    "$src" > "$dst"
}

for app in radarr sonarr prowlarr seerr jellyfin tautulli qbittorrent bazarr; do
  mkdir -p "$out/$app"
done

copy_redacted radarr/config/config.xml "$out/radarr/config.xml"
copy_redacted sonarr/config/config.xml "$out/sonarr/config.xml"
copy_redacted prowlarr/config/config.xml "$out/prowlarr/config.xml"
copy_redacted seerr/config/settings.json "$out/seerr/settings.json"
cp jellyfin/config/*.xml "$out/jellyfin/" 2>/dev/null || true
copy_redacted tautulli/config/config.ini "$out/tautulli/config.ini"
copy_redacted qbittorrent/config/qBittorrent/qBittorrent.conf "$out/qbittorrent/qBittorrent.conf"
copy_redacted bazarr/config/config/config.yaml "$out/bazarr/config.yaml"

cat > "$out/README.md" <<'EOF'
# Versioned application configuration

These files are a sanitized, reviewable baseline for rebuilding the Starr stack.
Runtime databases, logs, caches, media indexes, and credentials are intentionally excluded.
The live application data remains in each application's `config/` directory.

Run `scripts/export-config.sh` after intentional configuration changes and commit the diff.
Restore the compose stack first, then restore each application's settings through its UI or API.
EOF
