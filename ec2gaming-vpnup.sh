#!/usr/bin/env bash
source "$(dirname "$0")/ec2gaming.header"

echo -n "Connecting VPN (you may see an authentication prompt)... "
IP=$(./ec2gaming-instance-ip.sh)
BACKING_CONFIG=~/Library/Application\ Support/Tunnelblick/Configurations/ec2gaming.tblk/Contents/Resources/config.ovpn
if [ ! -f "$BACKING_CONFIG" ]; then
  sed "s#IP#$IP#g;s#AUTH#$(pwd)/ec2gaming.auth#g" ec2gaming.ovpn.template > ec2gaming.ovpn
  open ec2gaming.ovpn
  echo "Waiting 10 seconds for import..."
  sleep 10
else
    # the authentication prompt on copy will block, avoids the messy sleep
    sed "s#IP#$IP#g;s#AUTH#$(pwd)/ec2gaming.auth#g" ec2gaming.ovpn.template > "$BACKING_CONFIG"
fi

osascript ec2gaming-vpnup.scpt
