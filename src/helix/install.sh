#!/usr/bin/env bash
set -e

TARGET_VERSION="${VERSION:-"latest"}"
INSTALL_PREFIX="/usr/local"
RUNTIME_DIR="${INSTALL_PREFIX}/share/helix/runtime"

if [ "$(id -u)" -ne 0 ]; then
    echo "Script must be run as root."
    exit 1
fi

. /etc/os-release
if [ "${ID}" = "debian" ] || [ "${ID_LIKE}" = "debian" ] || [ "${ID_LIKE:-}" = *"debian"* ]; then
    ADJUSTED_ID="debian"
elif [[ "${ID}" = "rhel" || "${ID}" = "fedora" || "${ID_LIKE}" = *"rhel"* || "${ID_LIKE}" = *"fedora"* ]]; then
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

# Ensure curl, tar, and xz are available
need_pkgs=()
type curl >/dev/null 2>&1 || need_pkgs+=("curl")
type tar  >/dev/null 2>&1 || need_pkgs+=("tar")
if ! type xz >/dev/null 2>&1; then
    case "${ADJUSTED_ID}" in
        debian) need_pkgs+=("xz-utils") ;;
        rhel)   need_pkgs+=("xz") ;;
        alpine) need_pkgs+=("xz") ;;
    esac
fi
type ca-certificates >/dev/null 2>&1 || true
if [ "${ADJUSTED_ID}" = "debian" ]; then
    need_pkgs+=("ca-certificates")
fi
if [ "${#need_pkgs[@]}" -gt 0 ]; then
    install_pkgs "${need_pkgs[@]}"
fi

# Resolve version
if [ "${TARGET_VERSION}" = "latest" ] || [ -z "${TARGET_VERSION}" ]; then
    echo "Resolving latest Helix release..."
    TARGET_VERSION="$(curl -fsSL https://api.github.com/repos/helix-editor/helix/releases/latest \
        | grep '"tag_name":' | head -n1 | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/')"
    if [ -z "${TARGET_VERSION}" ]; then
        echo "Failed to resolve latest Helix version."
        exit 1
    fi
fi
echo "Installing Helix ${TARGET_VERSION}"

# Architecture
case "$(uname -m)" in
    x86_64|amd64)   ARCH="x86_64" ;;
    aarch64|arm64)  ARCH="aarch64" ;;
    *)
        echo "Architecture $(uname -m) is not supported by upstream Helix release tarballs."
        exit 1
        ;;
esac

TARBALL="helix-${TARGET_VERSION}-${ARCH}-linux.tar.xz"
URL="https://github.com/helix-editor/helix/releases/download/${TARGET_VERSION}/${TARBALL}"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

echo "Downloading ${URL}"
curl -fsSL -o "${TMP_DIR}/${TARBALL}" "${URL}"

echo "Extracting..."
tar -xJf "${TMP_DIR}/${TARBALL}" -C "${TMP_DIR}"
EXTRACTED_DIR="$(find "${TMP_DIR}" -maxdepth 1 -mindepth 1 -type d -name 'helix-*' | head -n1)"
if [ -z "${EXTRACTED_DIR}" ]; then
    echo "Could not find extracted helix directory."
    exit 1
fi

# Install binary
install -m 0755 "${EXTRACTED_DIR}/hx" "${INSTALL_PREFIX}/bin/hx"

# Install runtime (themes, language configs, grammars)
mkdir -p "$(dirname "${RUNTIME_DIR}")"
rm -rf "${RUNTIME_DIR}"
mv "${EXTRACTED_DIR}/runtime" "${RUNTIME_DIR}"
chmod -R a+rX "${RUNTIME_DIR}"

# Verify
"${INSTALL_PREFIX}/bin/hx" --version || {
    echo "Helix installation verification failed."
    exit 1
}

echo "Done! Helix ${TARGET_VERSION} installed at ${INSTALL_PREFIX}/bin/hx (runtime at ${RUNTIME_DIR})."
