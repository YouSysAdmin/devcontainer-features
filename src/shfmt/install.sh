#!/usr/bin/env bash
set -e

TARGET_VERSION="${VERSION:-latest}"

if [ "$(id -u)" -ne 0 ]; then
    echo "Script must be run as root."
    exit 1
fi

. /etc/os-release
if [ "${ID}" = "debian" ] || [[ "${ID_LIKE:-}" = *"debian"* ]]; then
    ADJUSTED_ID="debian"
elif [[ "${ID}" = "rhel" || "${ID}" = "fedora" || "${ID_LIKE:-}" = *"rhel"* || "${ID_LIKE:-}" = *"fedora"* ]]; then
    ADJUSTED_ID="rhel"
elif [ "${ID}" = "alpine" ]; then
    ADJUSTED_ID="alpine"
else
    echo "Linux distro ${ID} not supported."
    exit 1
fi

install_pkgs() {
    case "${ADJUSTED_ID}" in
        debian)
            export DEBIAN_FRONTEND=noninteractive
            if [ "$(find /var/lib/apt/lists/* 2>/dev/null | wc -l)" = "0" ]; then
                apt-get update -y
            fi
            apt-get -y install --no-install-recommends "$@"
            ;;
        rhel)
            if type microdnf >/dev/null 2>&1; then
                microdnf -y install "$@"
            elif type dnf >/dev/null 2>&1; then
                dnf -y install "$@"
            else
                yum -y install "$@"
            fi
            ;;
        alpine)
            apk add --no-cache "$@"
            ;;
    esac
}

need_pkgs=()
type curl >/dev/null 2>&1 || need_pkgs+=("curl")
if [ "${ADJUSTED_ID}" = "debian" ]; then
    [ -f /etc/ssl/certs/ca-certificates.crt ] || need_pkgs+=("ca-certificates")
fi
if [ "${#need_pkgs[@]}" -gt 0 ]; then
    install_pkgs "${need_pkgs[@]}"
fi

case "$(uname -m)" in
    x86_64|amd64)  ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *) echo "Architecture $(uname -m) is not supported."; exit 1 ;;
esac

if [ "${TARGET_VERSION}" = "latest" ] || [ -z "${TARGET_VERSION}" ]; then
    echo "Resolving latest shfmt release..."
    TARGET_VERSION="$(curl -fsSL https://api.github.com/repos/mvdan/sh/releases/latest \
        | grep '"tag_name":' | head -n1 | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/')"
    if [ -z "${TARGET_VERSION}" ]; then
        echo "Failed to resolve latest shfmt version."
        exit 1
    fi
fi
echo "Installing shfmt ${TARGET_VERSION}"

# shfmt is published as a single static binary (no archive)
URL="https://github.com/mvdan/sh/releases/download/${TARGET_VERSION}/shfmt_${TARGET_VERSION}_linux_${ARCH}"
echo "Downloading ${URL}"
curl -fsSL -o /usr/local/bin/shfmt "${URL}"
chmod 0755 /usr/local/bin/shfmt

shfmt --version
echo "Done! shfmt ${TARGET_VERSION} installed."
