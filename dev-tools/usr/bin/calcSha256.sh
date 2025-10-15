#!/bin/bash - 
#===============================================================================
#
#          FILE: calcSha256.sh
# 
#         USAGE: ./calcSha256.sh <path/filename>
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: bill@azul3d.com
#  ORGANIZATION: 
#       CREATED: 04/25/24 10:52
#      REVISION:  ---
#===============================================================================

set -o nounset 

if [ -z "$1" ]
then
    echo "Usage: $0 <file_path>"
    exit 1
fi

filename="$1"
hash=$(sha256sum "$filename" | cut -d ' ' -f1)
echo "$hash" > "${filename}.sha256sum"
