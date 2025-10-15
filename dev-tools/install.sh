#!/bin/bash - 
#===============================================================================
#
#          FILE: uninstall.sh
# 
#         USAGE: ./uninstall.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: billes.debruyn@gmail.com
#  ORGANIZATION: 
#       CREATED: 10/15/2025
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

REPO_PATH="$(pwd)/dev-tools"
OPT_TARGET="/opt"
USR_BIN_TARGET="/usr/local/bin"

echo "Installing from $REPO_PATH to $USR_BIN_TARGET"

# Create symbolic links in /opt
ln -sf "${REPO_PATH}/opt/containers" "${OPT_TARGET}/containers"

# Create symbolic links in /usr/bin
ln -sf "${REPO_PATH}/usr/bin/assh"                        "${USR_BIN_TARGET}/assh"
ln -sf "${REPO_PATH}/usr/bin/run-img"                     "${USR_BIN_TARGET}/run-img"
ln -sf "${REPO_PATH}/usr/bin/build-armv8-dunfell-img.sh"  "${USR_BIN_TARGET}/build-armv8-dunfell-img.sh"
ln -sf "${REPO_PATH}/usr/bin/build-jammy-x86_64-img.sh"   "${USR_BIN_TARGET}/build-jammy-x86_64-img.sh"
ln -sf "${REPO_PATH}/usr/bin/build-x86_64-img.sh"         "${USR_BIN_TARGET}/build-x86_64-img.sh"
ln -sf "${REPO_PATH}/usr/bin/build-x86_64-libcxx-img.sh"  "${USR_BIN_TARGET}/build-x86_64-libcxx-img.sh"
ln -sf "${REPO_PATH}/usr/bin/calcSha256.sh"               "${USR_BIN_TARGET}/calcSha256.sh"
ln -sf "${REPO_PATH}/usr/bin/fetchLatestImage.sh"         "${USR_BIN_TARGET}/fetchLatestImage.sh"
ln -sf "${REPO_PATH}/usr/bin/install-dev-tools.sh"        "${USR_BIN_TARGET}/install-dev-tools.sh"
ln -sf "${REPO_PATH}/usr/bin/ip-masquerading.sh"          "${USR_BIN_TARGET}/ip-masquerading.sh"
ln -sf "${REPO_PATH}/usr/bin/new-branch-for-all.sh"       "${USR_BIN_TARGET}/new-branch-for-all.sh"
ln -sf "${REPO_PATH}/usr/bin/remove-all-containers"       "${USR_BIN_TARGET}/remove-all-containers"
ln -sf "${REPO_PATH}/usr/bin/switch-test.sh"              "${USR_BIN_TARGET}/switch-test.sh"

echo "Symbolic links recreated with absolute paths successfully."
