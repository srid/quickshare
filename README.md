# quickshare

Share `.html` files on the web by uploading them to a Cloudflare R2 bucket fronted by your custom domain.

```sh
$ quickshare add ./foo.html
https://share.example.com/foo
```

## Setup

You need:

1. An R2 bucket with a public custom domain (e.g. `share.example.com`).
   See [R2 → Public buckets](https://developers.cloudflare.com/r2/buckets/public-buckets/).
2. A Cloudflare API token scoped to **R2 Storage: Edit** for that bucket.

Set these environment variables (e.g. in your shell profile):

| Variable                 | Example                       |
| ------------------------ | ----------------------------- |
| `CLOUDFLARE_API_TOKEN`   | `xxxxxxxxxxxxxxxxxxxxxxxxx`   |
| `CLOUDFLARE_ACCOUNT_ID`  | `abc123...`                   |
| `QUICKSHARE_R2_BUCKET`   | `share`                       |
| `QUICKSHARE_PUBLIC_URL`  | `https://share.example.com`   |

## Usage

```sh
nix run github:srid/quickshare -- add ./foo.html
```

Or install into your environment:

```sh
nix profile install github:srid/quickshare
quickshare add ./foo.html
```

The object key on R2 is the file's basename with `.html` stripped, so `foo.html` becomes `https://share.example.com/foo`. Re-running `add` on the same filename overwrites the existing object.

## Development

```sh
nix develop          # drops you into a shell with wrangler available
nix build            # builds and runs shellcheck via writeShellApplication
nix run .# -- --help
```
