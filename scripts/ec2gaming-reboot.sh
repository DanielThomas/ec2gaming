#!/usr/bin/env bash
source "$(dirname "$0")/ec2gaming.header"

INSTANCE_ID=$(./ec2gaming-instance.sh)
echo "Rebooting gaming instance ($INSTANCE_ID)..."
aws ec2 reboot-instances --instance-ids "$INSTANCE_ID" > /dev/null
