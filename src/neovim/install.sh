#!/usr/bin/env bash

NEOVIM_VERSION=${VERSION}

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Bring in ID, ID_LIKE, VERSION_ID, VERSION_CODENAME
. /etc/os-release
# Get an adjusted ID independent of distro variants
if [ "${ID}" = "debian" ] || [ "${ID_LIKE}" = "debian" ]; then
    ADJUSTED_ID="debian"
elif [ "${ID}" = "alpine" ]; then
    ADJUSTED_ID="alpine"
else
    echo "Linux distro ${ID} not supported."
    exit 1
fi

if type apt-get > /dev/null 2>&1; then
    INSTALL_CMD=apt-get
elif type apk > /dev/null 2>&1; then
    INSTALL_CMD=apk
else
    echo "(Error) Unable to find a supported package manager."
    exit 1
fi

# Clean up
clean_up() {
    case $ADJUSTED_ID in
        debian)
            rm -rf /var/lib/apt/lists/*
            ;;
        alpine)
            rm -rf /var/cache/apk/*
            ;;
    esac
}
clean_up

pkg_mgr_update() {
    if [ ${INSTALL_CMD} = "apt-get" ]; then
        if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
            echo "Running apt-get update..."
            ${INSTALL_CMD} update -y
        fi
    elif [ ${INSTALL_CMD} = "apk" ]; then
        if [ "$(find /var/cache/apk/* | wc -l)" = "0" ]; then
            echo "Running apk update..."
            ${INSTALL_CMD} update
        fi
    fi
}

# Checks if packages are installed and installs them if not
check_packages() {
    if [ ${INSTALL_CMD} = "apt-get" ]; then
        if ! dpkg -s "$@" > /dev/null 2>&1; then
            pkg_mgr_update
            ${INSTALL_CMD} -y install --no-install-recommends "$@"
        fi
    elif [ ${INSTALL_CMD} = "apk" ]; then
        ${INSTALL_CMD} add \
            --no-cache \
            "$@"
    else
        echo "Linux distro ${ID} not supported."
        exit 1
    fi
}

export DEBIAN_FRONTEND=noninteractive

# Install required packages to build if missing
if [ "${ADJUSTED_ID}" = "debian" ]; then
    check_packages ninja-build gettext cmake unzip curl build-essential ca-certificates
elif [ "${ADJUSTED_ID}" = "alpine" ]; then
    check_packages build-base cmake coreutils curl unzip gettext-tiny-dev
else
    echo "Linux distro ${ID} not supported."
    exit 1
fi

echo "Downloading source for ${NEOVIM_VERSION}..."
curl -sL https://github.com/neovim/neovim/archive/refs/tags/${NEOVIM_VERSION}.tar.gz | tar -xzC /tmp 2>&1
echo "Building..."
cd /tmp/neovim-${NEOVIM_VERSION}
make CMAKE_BUILD_TYPE=Release
make install
rm -rf /tmp/neovim-${NEOVIM_VERSION}
clean_up
echo "Done!"
