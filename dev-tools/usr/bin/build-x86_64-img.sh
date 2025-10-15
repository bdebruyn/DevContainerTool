#!/bin/bash - 
#===============================================================================
#
#          FILE: build-x86_64-img.sh
# 
#         USAGE: ./build-x86_64-img.sh 
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

# Assign default value to "os" if $1 has no value
os="${1:-ubuntu:20.04}"

img="x86_64-img"

cd /opt/containers/docker-common-img; ./RunConfig.sh focal-x86-img.yaml
