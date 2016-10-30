#!/usr/bin/env bash
source "$(dirname "$0")/ec2gaming.header"

INSTANCE_ID=$(./ec2gaming-instance.sh)
aws ec2 describe-instances --instance-ids "$INSTANCE_ID" | jq --raw-output '.Reservations[0].Instances[0].PublicIpAddress'
