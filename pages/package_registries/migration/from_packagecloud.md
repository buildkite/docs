# Export from Packagecloud

To migrate your packages from Packagecloud to Buildkite Package Registries, you'll need to export and download packages from a Packagecloud repository before importing them to your Buildkite registry.

Packagecloud doesn't provide a built-in bulk export feature, so this guide uses the Packagecloud REST API to list and download all packages.

## Before you start

To export the packages, you'll need:

- A Packagecloud account with access to the repository you want to export
- Your Packagecloud API token
- `curl` installed on your system
- `jq` installed for JSON processing (install using `brew install jq` on macOS or `apt install jq` on Debian/Ubuntu)
- Sufficient disk space for your packages

## Get your Packagecloud API token

1. Log in to [packagecloud.io](https://packagecloud.io).
1. Navigate to [packagecloud.io/api_token](https://packagecloud.io/api_token).
1. Copy your API token and store it securely.

## Export all packages from a repository

The following shell script exports all packages from a Packagecloud repository to a local directory. It handles pagination automatically and preserves the original filenames.

To be able to use the script, create a file named `export-packagecloud.sh` with the following content:

```bash
#!/bin/bash
set -euo pipefail

PACKAGECLOUD_TOKEN="${PACKAGECLOUD_TOKEN:-}"
PACKAGECLOUD_USER="${PACKAGECLOUD_USER:-}"
PACKAGECLOUD_REPO="${PACKAGECLOUD_REPO:-}"
OUTPUT_DIR="${OUTPUT_DIR:-./packagecloud-export}"
PER_PAGE=100

if [[ -z "$PACKAGECLOUD_TOKEN" ]]; then
    echo "Error: PACKAGECLOUD_TOKEN environment variable is required"
    exit 1
fi

if [[ -z "$PACKAGECLOUD_USER" ]]; then
    echo "Error: PACKAGECLOUD_USER environment variable is required"
    exit 1
fi

if [[ -z "$PACKAGECLOUD_REPO" ]]; then
    echo "Error: PACKAGECLOUD_REPO environment variable is required"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

echo "Exporting packages from packagecloud.io/${PACKAGECLOUD_USER}/${PACKAGECLOUD_REPO}"
echo "Output directory: $OUTPUT_DIR"

fetch_all_packages() {
    local page=1
    local all_packages="[]"

    while true; do
        echo "Fetching page $page..."

        response=$(curl -s -u "${PACKAGECLOUD_TOKEN}:" \
            "https://packagecloud.io/api/v1/repos/${PACKAGECLOUD_USER}/${PACKAGECLOUD_REPO}/packages.json?per_page=${PER_PAGE}&page=${page}")

        if ! echo "$response" | jq -e 'type == "array"' > /dev/null 2>&1; then
            echo "Error: Invalid API response on page $page"
            echo "$response"
            exit 1
        fi

        count=$(echo "$response" | jq 'length')

        if [[ "$count" -eq 0 ]]; then
            break
        fi

        echo "Found $count packages on page $page"
        all_packages=$(echo "$all_packages" "$response" | jq -s 'add')

        if [[ "$count" -lt "$PER_PAGE" ]]; then
            break
        fi

        page=$((page + 1))
    done

    echo "$all_packages"
}

packages=$(fetch_all_packages)
total=$(echo "$packages" | jq 'length')
echo "Total packages to download: $total"

echo "$packages" | jq '.' > "${OUTPUT_DIR}/manifest.json"
echo "Package manifest saved to ${OUTPUT_DIR}/manifest.json"

echo "$packages" | jq -c '.[]' | while read -r package; do
    filename=$(echo "$package" | jq -r '.filename')
    package_url=$(echo "$package" | jq -r '.package_url')
    package_type=$(echo "$package" | jq -r '.type')

    type_dir="${OUTPUT_DIR}/${package_type}/${PACKAGECLOUD_REPO}"
    mkdir -p "$type_dir"

    output_path="${type_dir}/${filename}"

    if [[ -f "$output_path" ]]; then
        echo "Skipping (already exists): $filename"
        continue
    fi

    echo "Downloading: $filename"

    package_details=$(curl -s -u "${PACKAGECLOUD_TOKEN}:" \
        "https://packagecloud.io${package_url}")

    download_url=$(echo "$package_details" | jq -r '.download_url // empty')

    if [[ -z "$download_url" ]]; then
        echo "  Warning: No download URL found for $filename, skipping"
        continue
    fi

    if curl -s -L -u "${PACKAGECLOUD_TOKEN}:" -o "$output_path" "$download_url"; then
        echo "  Saved to: $output_path"
    else
        echo "  Error: Failed to download $filename"
        rm -f "$output_path"
    fi
done

echo "Export complete. Output directory: $OUTPUT_DIR"
```
{: codeblock-file="export-packagecloud.sh"}

Make the script executable and run it:

```bash
chmod +x export-packagecloud.sh

export PACKAGECLOUD_TOKEN="your-api-token"
export PACKAGECLOUD_USER="your-username"
export PACKAGECLOUD_REPO="your-repository"

./export-packagecloud.sh
```

The script creates the following directory structure, organizing packages by ecosystem type and source repository:

```
packagecloud-export/
├── manifest.json
├── deb/
│   └── my-repo/
│       └── example_1.0.0_amd64.deb
├── rpm/
│   └── my-repo/
│       └── example-1.0.0-1.x86_64.rpm
└── gem/
    └── my-repo/
        └── example-1.0.0.gem
```

Each top-level folder (`deb/`, `rpm/`, `gem/`) maps to one Buildkite registry. The repository subdirectory preserves the source Packagecloud repository name, which is useful when exporting multiple repositories.

To import all Debian packages into a Buildkite Debian registry, run:

```bash
find ./packagecloud-export/deb -name "*.deb" -exec bk package push my-debian-registry {} \;
```

## Export packages manually

For smaller repositories or if you would like to have more control over the export process, you can use curl commands directly. Follow the instructions and commands in the sections below.

### List all packages in a repository

```bash
curl -s -u "YOUR_API_TOKEN:" \
    "https://packagecloud.io/api/v1/repos/USERNAME/REPO/packages.json?per_page=100" \
    | jq '.'
```

Replace `YOUR_API_TOKEN`, `USERNAME`, and `REPO` with your values. Note the trailing colon after the token as it is required for HTTP basic authentication with an empty password.

### Get package details and download URL

The package list response includes a `package_url` field. Use this to fetch the package details, which contain the `download_url`:

```bash
curl -s -u "YOUR_API_TOKEN:" \
    "https://packagecloud.io/api/v1/repos/USERNAME/REPO/package/TYPE/DISTRO/VERSION/FILENAME.json" \
    | jq '.download_url'
```

### Download a package

```bash
curl -L -u "YOUR_API_TOKEN:" \
    -o "package-filename.deb" \
    "DOWNLOAD_URL"
```

## Handling pagination

The Packagecloud API returns a maximum of 100 packages per request. For repositories with more packages, use the `page` query parameter:

```bash
curl -s -u "YOUR_API_TOKEN:" \
    "https://packagecloud.io/api/v1/repos/USERNAME/REPO/packages.json?per_page=100&page=2"
```

The API provides pagination information in response headers:

- `Total`: Total number of packages
- `Per-Page`: Number of packages per page
- `Link`: Links to next, previous, and last pages

## Troubleshooting

This section covers the potential issues you might run into when bulk-exporting your packages from Packagecloud following the instructions in this guide and how to solve them.

### Authentication errors

If you receive a 401 Unauthorized response, verify that:

- Your API token is correct
- The token is passed as the username with an empty password (note the trailing colon in `-u "TOKEN:"`)

### Rate limiting

Packagecloud may rate limit API requests. If you encounter rate limiting:

- Add a delay between downloads by inserting `sleep 1` in the download loop
- Run the export during off-peak hours

### Missing download URLs

Some package types use different API endpoints. If a package doesn't have a `download_url` in the response, check the [Packagecloud API documentation](https://packagecloud.io/docs/api) for the correct endpoint for that package type.

### Non-version-agnostic packages

For deb, rpm, and alpine packages, migration works only if your packages are distribution version-agnostic (for example, a package works on all Ubuntu versions such as Focal and Jammy). If your packages target specific distribution versions, contact [Buildkite support](mailto:support@buildkite.com) before proceeding.

## Next step

Once you have downloaded your packages from your Packagecloud repositories, learn how to [import them into your Buildkite registry](/docs/package-registries/migration/import-to-package-registries).

> 🚧 Repository signing keys
> Buildkite Package Registries signs repository metadata with its own keys, not your Packagecloud keys. After migration, update your clients (apt, yum, apk) to use the new signing keys from your Buildkite registry.
