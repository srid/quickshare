#!/usr/bin/env bash
set -euo pipefail

# Single source of truth: NAME|description for each required env var.
required_envs=(
  'CLOUDFLARE_API_TOKEN|API token with "R2 Storage: Edit" permission.'
  'CLOUDFLARE_ACCOUNT_ID|Cloudflare account ID owning the bucket.'
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

require_env() {
  local name="$1"
  if [[ -z "${!name:-}" ]]; then
    echo "quickshare: $name is not set" >&2
    exit 1
  fi
}

cmd_add() {
  local file="${1:-}"
  if [[ -z "$file" ]]; then
    usage
    exit 2
  fi
  if [[ ! -f "$file" ]]; then
    echo "quickshare: file not found: $file" >&2
    exit 1
  fi
  if [[ "$file" != *.html ]]; then
    echo "quickshare: only .html files are supported" >&2
    exit 1
  fi

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
