#!/usr/bin/env bash
source "$(dirname "$0")/ec2gaming.header"

echo "Starting Remote Desktop..."
IP=$(./ec2gaming-instance-ip.sh)
sed "s/IP/$IP/g" ec2gaming.rdp.template > ec2gaming.rdp
open ec2gaming.rdp
