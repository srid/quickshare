#!/usr/bin/env bash
set -euo pipefail

# Single source of truth: NAME|description for each required env var.
# Cloudflare auth is handled by `wrangler login` (OAuth token cached on disk),
# so no CLOUDFLARE_* vars are needed here.
required_envs=(
  'QUICKSHARE_R2_BUCKET|R2 bucket name.'
  'QUICKSHARE_PUBLIC_URL|Public base URL bound to the bucket (e.g. https://share.srid.ca).'
)

usage() {
  {
    echo "Usage: quickshare add <file.html>"
    echo
    echo "Upload an HTML file to a Cloudflare R2 bucket and print its public URL."
    echo
    echo "Required environment variables:"
    local entry
    for entry in "${required_envs[@]}"; do
      printf '  %-24s %s\n' "${entry%%|*}" "${entry#*|}"
    done
  } >&2
}

die() {
  echo "quickshare: $1" >&2
  exit 1
}

require_env() {
  local name="$1"
  [[ -n "${!name:-}" ]] || die "$name is not set"
}

cmd_add() {
  local file="${1:-}"
  if [[ -z "$file" ]]; then
    usage
    exit 2
  fi
  [[ -f "$file" ]] || die "file not found: $file"
  [[ "$file" == *.html ]] || die "only .html files are supported"

  local entry
  for entry in "${required_envs[@]}"; do
    require_env "${entry%%|*}"
  done

  local name
  name="$(basename "$file" .html)"

  wrangler r2 object put \
    "${QUICKSHARE_R2_BUCKET}/${name}" \
    --file "$file" \
    --content-type "text/html" \
    --remote >&2

  echo "${QUICKSHARE_PUBLIC_URL%/}/${name}"
}

main() {
  local sub="${1:-}"
  case "$sub" in
    add)
      shift
      cmd_add "$@"
      ;;
    -h | --help | help)
      usage
      exit 0
      ;;
    "")
      usage
      exit 2
      ;;
    *)
      echo "quickshare: unknown subcommand: $sub" >&2
      usage
      exit 2
      ;;
  esac
}

main "$@"
