#!/bin/bash
set -e

INSTANCE_ID=$(./ec2gaming-instance.sh)
echo "Terminating gaming instance ($INSTANCE_ID)..."
aws ec2 terminate-instances --instance-ids "$INSTANCE_ID" > /dev/null
