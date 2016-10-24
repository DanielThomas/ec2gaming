#!/bin/bash

set -e

echo -n "Disconnecting VPN... "
osascript ec2gaming-vpndown.scpt

# Verify that the gaming stane actually exists (and that there's only one)
echo -n "Finding your gaming instance... "
INSTANCES=$( aws ec2 describe-instances --filters Name=instance-state-code,Values=16 Name=instance-type,Values=g2.2xlarge )
if [ $( echo "$INSTANCES" | jq '.Reservations | length' ) -ne "1" ]; then
	echo "didnt find exactly one instance!"
	exit
fi
INSTANCE_ID=$( echo "$INSTANCES" | jq --raw-output '.Reservations[0].Instances[0].InstanceId' )
echo "$INSTANCE_ID"

echo "Terminating gaming instance..."
aws ec2 terminate-instances --instance-ids "$INSTANCE_ID" > /dev/null

echo "All done!"