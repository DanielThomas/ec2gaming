#!/usr/bin/env bash
set -e

# Verify that the gaming stane actually exists (and that there's only one)
INSTANCES=$(aws ec2 describe-instances --filters Name=instance-state-code,Values=16 Name=instance-type,Values=g2.2xlarge)
if [ "$(echo "$INSTANCES" | jq '.Reservations | length')" -ne "1" ]; then
    >&2 echo "didn't find an instance or there wasn't exactly one g2.2xlarge instance"
    exit 1
fi
echo "$INSTANCES" | jq --raw-output '.Reservations[0].Instances[0].InstanceId'
