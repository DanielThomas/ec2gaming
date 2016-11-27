#!/usr/bin/env bash
source "$(dirname "$0")/ec2gaming.header"

echo -n "Disconnecting VPN... "
osascript "ec2gaming-vpndown.$VPN_CLIENT.scpt"
