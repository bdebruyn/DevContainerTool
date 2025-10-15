#!/bin/bash - 
#===============================================================================
#
#          FILE: build-armv8-img.sh
# 
#         USAGE: ./build-armv8-img.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: bill@azul3d.com
#  ORGANIZATION: 
#       CREATED: 08/30/2021 18:01
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

img="armv8-dunfell-img"

cd /opt/containers/docker-common-img; ./RunConfig.sh focal-armv8-img.yaml
