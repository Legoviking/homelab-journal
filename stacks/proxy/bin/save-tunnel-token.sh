#!/usr/bin/env bash
# Reads the 1Password field on stdin (token alone, or the whole "docker run ... --token eyJ..."
# command), keeps only the eyJ... token, and saves it with chmod 600. Prints only its length.
set -euo pipefail
umask 077
dir=/opt/stacks/proxy/secrets
mkdir -p "$dir"
tok=$(LC_ALL=C grep -oE 'eyJ[A-Za-z0-9_=+/-]+' | head -n1 || true)
if [ ${#tok} -lt 100 ]; then echo "token missing or too short (${#tok}); nothing saved" >&2; exit 1; fi
printf '%s' "$tok" > "$dir/cf_tunnel_token"
echo "saved cf_tunnel_token, length ${#tok}"
