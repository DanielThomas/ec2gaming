#!/usr/bin/env bash
INSTANCES=$(aws ec2 describe-instances --filters Name=instance-state-code,Values=16 Name=instance-type,Values=g2.2xlarge)
if [ "$(echo "$INSTANCES" | jq '.Reservations | length' )" -ne "1" ]; then
    echo "didnt find exactly one instance!"
    exit
fi
INSTANCE_ID=$(echo "$INSTANCES" | jq --raw-output '.Reservations[0].Instances[0].InstanceId')
echo "running on $INSTANCE_ID"
