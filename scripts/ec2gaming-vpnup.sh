#!/usr/bin/env bash
source "$(dirname "$0")/ec2gaming.header"

echo -n "Connecting VPN (you may see an authentication prompt)... "
IP=$(./ec2gaming-ip.sh)
AUTH=$(realpath "$(pwd)/../ec2gaming.auth")
CONFIG_EXISTS=0

# Find if config exists
if [ "$VPN_CLIENT" = "tunnelblick" ]; then
  BACKING_CONFIG=~/Library/Application\ Support/Tunnelblick/Configurations/ec2gaming.tblk/Contents/Resources/config.ovpn
  if [ -f "$BACKING_CONFIG" ]; then
    CONFIG_EXISTS=1
    # the authentication prompt on copy will block, avoids the messy sleep
    sed "s#IP#$IP#g;s#AUTH#$AUTH#g" ec2gaming.ovpn.template > "$BACKING_CONFIG"
  fi
elif [ "$VPN_CLIENT" = "viscosity" ]; then
  grep -R ec2gaming ~/Library/Application\ Support/Viscosity/OpenVPN > /dev/null
  if [ $? -eq 0 ]; then
    CONFIG_EXISTS=1
  fi
fi

# Create config if needed
if [ $CONFIG_EXISTS -eq 0 ]; then
  sed "s#IP#$IP#g;s#AUTH#$AUTH#g" ec2gaming.ovpn.template > ec2gaming.ovpn
  open ec2gaming.ovpn
  echo "Waiting 10 seconds for import...\n"
  sleep 10
fi

osascript "ec2gaming-vpnup.$VPN_CLIENT.scpt"
