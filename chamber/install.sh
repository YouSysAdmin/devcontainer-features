set -e

. ./library_scripts.sh

ensure_nanolayer nanolayer_location "v0.5.4"


$nanolayer_location \
    install \
    devcontainer-feature \
    "ghcr.io/devcontainers-contrib/features/gh-release:1.0.25" \
    --option repo='segmentio/chamber' --option binaryNames='chamber' --option version="$VERSION"
