#!/bin/bash

if [ $(id -u) != 0 ]; then
   echo "ERROR: run as root"
   exit 1
fi

for i in "$@"; do
  case $i in
    -h=*|--WIFI_CONNECTED_GATEWAY=*)
      WIFI_CONNECTED_GATEWAY="${i#*=}"
      shift # past argument=value
      ;;
    -t=*|--SUBNET_GATEWAY=*)
      SUBNET_GATEWAY="${i#*=}"
      shift # past argument=value
      ;;
    --default)
      DEFAULT=YES
      shift # past argument with no value
      ;;
    *)
      # unknown option
      ;;
  esac
done

if [[ -z "$WIFI_CONNECTED_GATEWAY" || -z "$SUBNET_GATEWAY" ]]; then
  echo "ERROR: ip-masquerade -h=<WIFI_CONNECTED_GATEWAY ip address> -t=<SUBNET_GATEWAY ip address> "
  exit 1
fi

echo "WIFI_CONNECTED_GATEWAY   = ${WIFI_CONNECTED_GATEWAY}"
echo "SUBNET_GATEWAY = ${SUBNET_GATEWAY}"

isHost=$(ip a |grep -o "$WIFI_CONNECTED_GATEWAY" |wc -l)
isTarget=$(ip a |grep -o "$SUBNET_GATEWAY" |wc -l)

echo "isHost   = <${isHost}>"
echo "isTarget = <${isTarget}>"


if [[ "$isHost" -eq "0" ]]; then
  echo "ERROR: ${WIFI_CONNECTED_GATEWAY} does not match any names:"
  exit 1
fi

if [[ "$isTarget" -eq "0" ]]; then
  echo "ERROR: ${SUBNET_GATEWAY} does not match any names:"
  exit 1
fi

if [ $(id -u) != 0 ]; then
   echo "ERROR: run as root"
   exit 1
fi

echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -F
iptables -t nat -F
iptables -A FORWARD -i ${SUBNET_GATEWAY} -o ${WIFI_CONNECTED_GATEWAY} -j ACCEPT
iptables -A FORWARD -i ${WIFI_CONNECTED_GATEWAY} -o ${SUBNET_GATEWAY} -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -t nat -A POSTROUTING -o ${SUBNET_GATEWAY} -j MASQUERADE

