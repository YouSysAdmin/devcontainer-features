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

# Use upstream installer (handles arch detection + checksum verification)
INSTALL_ARGS=(-b /usr/local/bin)
if [ "${TARGET_VERSION}" != "latest" ] && [ -n "${TARGET_VERSION}" ]; then
    INSTALL_ARGS+=("${TARGET_VERSION}")
fi

curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh \
    | sh -s -- "${INSTALL_ARGS[@]}"

trivy --version
echo "Done! Trivy installed at /usr/local/bin/trivy."
