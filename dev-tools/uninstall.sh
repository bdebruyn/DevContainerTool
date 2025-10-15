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

# Target paths
OPT_TARGET="/opt"
USR_BIN_TARGET="/usr/local/bin"

# Remove symbolic links in /opt
rm -rf "${OPT_TARGET}/containers"

# Remove symbolic links in /usr/bin
rm -f "${USR_BIN_TARGET}/assh"
rm -f "${USR_BIN_TARGET}/build-armv8-dunfell-img.sh"
rm -f "${USR_BIN_TARGET}/build-armv8-zeus-img.sh"
rm -f "${USR_BIN_TARGET}/build-hpc-img.sh"
rm -f "${USR_BIN_TARGET}/build-nvidia-img.sh"
rm -f "${USR_BIN_TARGET}/build-jammy-x86_64-img.sh"
rm -f "${USR_BIN_TARGET}/build-x86_64-img.sh"
rm -f "${USR_BIN_TARGET}/build-x86_64-libcxx-img.sh"
rm -f "${USR_BIN_TARGET}/build-yocto-img.sh"
rm -f "${USR_BIN_TARGET}/calcSha256.sh"
rm -f "${USR_BIN_TARGET}/fetchLatestImage.sh"
rm -f "${USR_BIN_TARGET}/install-dev-tools.sh"
rm -f "${USR_BIN_TARGET}/ip-masquerading.sh"
rm -f "${USR_BIN_TARGET}/new-branch-for-all.sh"
rm -f "${USR_BIN_TARGET}/remove-all-containers"
rm -f "${USR_BIN_TARGET}/run-img"
rm -f "${USR_BIN_TARGET}/switch-test.sh"

echo "Symbolic links removed successfully."

