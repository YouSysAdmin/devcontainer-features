#!/usr/bin/env bash
set -e

TARGET_VERSION="${VERSION:-latest}"
VENV_DIR="/usr/local/share/yapf-venv"

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

# Base packages: python3 + venv
case "${ADJUSTED_ID}" in
    debian) install_pkgs python3 python3-venv python3-pip ca-certificates ;;
    rhel)   install_pkgs python3 python3-pip ca-certificates ;;
    alpine) install_pkgs python3 py3-pip ca-certificates ;;
esac

# Build the venv
python3 -m venv "${VENV_DIR}"
"${VENV_DIR}/bin/pip" install --no-cache-dir --upgrade pip wheel

YAPF_SPEC="yapf"
if [ "${TARGET_VERSION}" != "latest" ] && [ -n "${TARGET_VERSION}" ]; then
    YAPF_SPEC="yapf==${TARGET_VERSION}"
fi

echo "Installing ${YAPF_SPEC}..."
"${VENV_DIR}/bin/pip" install --no-cache-dir "${YAPF_SPEC}"

# Symlink into /usr/local/bin
ln -sf "${VENV_DIR}/bin/yapf"     /usr/local/bin/yapf
ln -sf "${VENV_DIR}/bin/yapf-diff" /usr/local/bin/yapf-diff 2>/dev/null || true

# Verify
yapf --version

echo "Done! yapf installed (venv: ${VENV_DIR})."
