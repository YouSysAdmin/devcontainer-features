set -e

. ./library_scripts.sh

ensure_nanolayer nanolayer_location "v0.5.4"

$nanolayer_location \
    install \
    devcontainer-feature \
    "ghcr.io/devcontainers-contrib/features/gh-release:1.0.25" \
    --option repo='yousysadmin/jc2aws' \
    --option binaryNames='jc2aws' \
    --option version="$VERSION" \
    --option assetRegex='jc2aws_v.*_linux_(amd64|arm64)\.tar\.gz$'
