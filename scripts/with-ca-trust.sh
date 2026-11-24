#!/bin/sh

set -eu

if ! command -v update-ca-certificates >/dev/null 2>&1; then
  if command -v apk >/dev/null 2>&1; then
    apk add --no-cache ca-certificates
  else
    apt-get update
    apt-get install -y --no-install-recommends ca-certificates
  fi
fi

# Include AAA to close the alternate cross-signed path.
sed -i -e '/^mozilla\/emSign_/s/^/!/' \
  -e '/^mozilla\/Comodo_AAA_Services_root\.crt$/s/^/!/' /etc/ca-certificates.conf
update-ca-certificates --fresh

# Updating the OS bundle alone does not change Node's bundled trust.
export NODE_OPTIONS="${NODE_OPTIONS:+$NODE_OPTIONS }--use-openssl-ca"
exec "$@"
