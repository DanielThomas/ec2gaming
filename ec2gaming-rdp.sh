#!/usr/bin/env bash
set -e

echo "Starting Remote Desktop..."
sed "s/IP/$IP/g" ec2gaming.rdp.template > ec2gaming.rdp
open ec2gaming.rdp
