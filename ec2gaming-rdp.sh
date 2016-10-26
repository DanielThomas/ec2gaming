#!/usr/bin/env bash
set -e

echo "Starting Remote Desktop..."
IP=$(./ec2gaming-instance-ip.sh)
sed "s/IP/$IP/g" ec2gaming.rdp.template > ec2gaming.rdp
open ec2gaming.rdp
