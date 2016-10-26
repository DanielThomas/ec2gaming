#!/bin/bash

set -e

echo -n "Disconnecting VPN... "
osascript ec2gaming-vpndown.scpt

INSTANCE_ID=$(./ec2gaming-instance.sh)

# Only allow one ec2gaming AMI to exist
echo -n "Checking if an AMI 'ec2gaming' already exists... "
AMIS=$( aws ec2 describe-images --owner self --filters Name=name,Values=ec2gaming )
if [ $( echo "$AMIS" | jq '.Images | length' ) -ne "0" ]; then
	AMI_ID=$( echo "$AMIS" | jq --raw-output '.Images[0].ImageId' )
	echo "yes, $AMI_ID"
	echo "Deregistering that AMI..."
	aws ec2 deregister-image --image-id $AMI_ID
	echo "Deleting AMI's backing Snapshot..."
	aws ec2 delete-snapshot --snapshot-id $( echo "$AMIS" | jq --raw-output '.Images[0].BlockDeviceMappings[0].Ebs.SnapshotId' )
else
	echo "no"
fi

# Create an AMI from the existing instance (so we can restore it next time)
echo -n "Starting AMI creation... "
AMI_ID=$( aws ec2 create-image --instance-id "$INSTANCE_ID" --name "ec2gaming" | jq --raw-output '.ImageId' )
echo "$AMI_ID"

echo "Waiting for AMI to be created..."
if ! aws ec2 wait image-available --image-id "$AMI_ID"; then 
	echo "AMI never finished being created!";
	exit
fi
