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

# Only allow one ec2-gaming AMI to exist
echo -n "Checking if an AMI 'ec2-gaming' already exists... "
AMIS=$( aws ec2 describe-images --owner self --filters Name=name,Values=ec2-gaming )
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
AMI_ID=$( aws ec2 create-image --instance-id "$INSTANCE_ID" --name "ec2-gaming" | jq --raw-output '.ImageId' )
echo "$AMI_ID"

echo "Waiting for AMI to be created before terminating instance..."
if ! aws ec2 wait image-available --image-id "$AMI_ID"; then 
	echo "AMI never finished being created! Instance not terminated!";
	exit
fi

# Now that an image has been created terminate the instance
echo "Terminating gaming instance..."
aws ec2 terminate-instances --instance-ids "$INSTANCE_ID" > /dev/null

echo "All done!"