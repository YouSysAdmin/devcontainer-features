#!/usr/bin/env bash
set -e

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

case "${ADJUSTED_ID}" in
    debian)
        export DEBIAN_FRONTEND=noninteractive
        if [ "$(find /var/lib/apt/lists/* 2>/dev/null | wc -l)" = "0" ]; then
            apt-get update -y
        fi
        apt-get -y install --no-install-recommends shellcheck
        ;;
    rhel)
        # Fedora / RHEL package is "ShellCheck" (capitalised)
        if type microdnf >/dev/null 2>&1; then
            microdnf -y install ShellCheck
        elif type dnf >/dev/null 2>&1; then
            dnf -y install ShellCheck
        else
            yum -y install ShellCheck
        fi
        ;;
    alpine)
        apk add --no-cache shellcheck
        ;;
esac

shellcheck --version
echo "Done! ShellCheck installed."
