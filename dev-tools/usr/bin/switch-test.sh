#!/bin/bash - 
#===============================================================================
#
#          FILE: switch_test.sh
# 
#         USAGE: ./switch_test.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 07/28/22 11:29
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

iperf3 -t 100 -c 192.168.10.11 &> LE1.txt &
iperf3 -t 100 -c 192.168.10.12 &> LE2.txt &
iperf3 -t 100 -c 192.168.10.13 &> LE3.txt &
iperf3 -t 100 -c 192.168.10.14 &> LE4.txt &
iperf3 -t 100 -c 192.168.10.15 &> LE5.txt &
iperf3 -t 100 -c 192.168.10.16 &> LE6.txt &
iperf3 -t 100 -c 192.168.10.17 &> LE7.txt &
iperf3 -t 100 -c 192.168.10.18 &> LE8.txt &

sleep 120
echo done!

tail -n 6 LE1.txt
tail -n 6 LE2.txt
tail -n 6 LE3.txt
tail -n 6 LE4.txt
tail -n 6 LE5.txt
tail -n 6 LE6.txt
tail -n 6 LE7.txt
tail -n 6 LE8.txt
