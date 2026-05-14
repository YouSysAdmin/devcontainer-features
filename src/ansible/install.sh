#!/usr/bin/env bash
set -e

TARGET_VERSION="${VERSION:-"latest"}"
TARGET_LINT_VERSION="${LINTVERSION:-"latest"}"
VENV_DIR="/usr/local/share/ansible-venv"

if [ "$(id -u)" -ne 0 ]; then
    echo "Script must be run as root."
    exit 1
fi

. /etc/os-release
if [ "${ID}" = "debian" ] || [ "${ID_LIKE:-}" = "debian" ] || [[ "${ID_LIKE:-}" = *"debian"* ]]; then
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

# Base packages: python3, venv, ssh client (Ansible's primary transport)
case "${ADJUSTED_ID}" in
    debian) install_pkgs python3 python3-venv python3-pip openssh-client ca-certificates ;;
    rhel)   install_pkgs python3 python3-pip openssh-clients ca-certificates ;;
    alpine) install_pkgs python3 py3-pip openssh-client ca-certificates ;;
esac

# Build the venv
python3 -m venv "${VENV_DIR}"
"${VENV_DIR}/bin/pip" install --no-cache-dir --upgrade pip wheel

ANSIBLE_CORE_SPEC="ansible-core"
if [ "${TARGET_VERSION}" != "latest" ] && [ -n "${TARGET_VERSION}" ]; then
    ANSIBLE_CORE_SPEC="ansible-core==${TARGET_VERSION}"
fi

ANSIBLE_LINT_SPEC="ansible-lint"
if [ "${TARGET_LINT_VERSION}" != "latest" ] && [ -n "${TARGET_LINT_VERSION}" ]; then
    ANSIBLE_LINT_SPEC="ansible-lint==${TARGET_LINT_VERSION}"
fi

echo "Installing ${ANSIBLE_CORE_SPEC} and ${ANSIBLE_LINT_SPEC}..."
"${VENV_DIR}/bin/pip" install --no-cache-dir "${ANSIBLE_CORE_SPEC}" "${ANSIBLE_LINT_SPEC}"

# Expose binaries system-wide via symlinks
for bin in "${VENV_DIR}/bin/"ansible*; do
    [ -x "${bin}" ] || continue
    name="$(basename "${bin}")"
    ln -sf "${bin}" "/usr/local/bin/${name}"
done

# Verify
/usr/local/bin/ansible --version
/usr/local/bin/ansible-lint --version

echo "Done! ansible-core and ansible-lint installed (venv: ${VENV_DIR})."
