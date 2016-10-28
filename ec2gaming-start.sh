#!/bin/bash
source "$(dirname "$0")/ec2gaming.header"

BOOTSTRAP=0

echo -n "Getting lowest g2.2xlarge bid... "
PRICE_AND_ZONE=($(./ec2gaming-price.sh))
PRICE=${PRICE_AND_ZONE[0]}
ZONE=${PRICE_AND_ZONE[1]}
echo "$PRICE in $ZONE"

FINAL_SPOT_PRICE=$(bc <<< "$PRICE + $SPOT_PRICE_BUFFER")
echo "Setting price for spot instance at $FINAL_SPOT_PRICE ($SPOT_PRICE_BUFFER higher than lowest spot price)"

echo -n "Looking for the ec2gaming AMI... "
AMI_SEARCH=$(describe_gaming_image self)
if [ "$(num_images "$AMI_SEARCH")" -eq "0" ]; then
	echo -n "not found. Going into bootstrap mode... "
  BOOTSTRAP=1
  AMI_SEARCH=$(describe_gaming_image 255191696678)
  if [ "$(num_images "$AMI_SEARCH")" -eq "0" ]; then
    echo "not found. Exiting."
    exit 1
  fi
fi
AMI_ID="$(echo "$AMI_SEARCH" | jq --raw-output '.Images[0].ImageId')"
echo "$AMI_ID"

echo -n "Looking for security groups... "
EC2_SECURITY_GROUP_ID=$(describe_security_group ec2gaming)
if [ -z "$EC2_SECURITY_GROUP_ID" ]; then
  echo -n "not found. Creating security group... "
  aws ec2 create-security-group --group-name ec2gaming --description "EC2 Gaming" > /dev/null
  aws ec2 authorize-security-group-ingress --group-name ec2gaming --protocol tcp --port 3389 --cidr "0.0.0.0/0"
  aws ec2 authorize-security-group-ingress --group-name ec2gaming --protocol tcp --port 1194 --cidr "0.0.0.0/0"
  aws ec2 authorize-security-group-ingress --group-name ec2gaming --protocol udp --port 1194 --cidr "0.0.0.0/0"
  EC2_SECURITY_GROUP_ID=$(describe_security_group ec2gaming)
fi

echo "$EC2_SECURITY_GROUP_ID"

echo -n "Creating spot instance request... "
SPOT_INSTANCE_ID=$(aws ec2 request-spot-instances --spot-price "$FINAL_SPOT_PRICE" --launch-specification "
  {
    \"SecurityGroupIds\": [\"$EC2_SECURITY_GROUP_ID\"],
    \"ImageId\": \"$AMI_ID\",
    \"InstanceType\": \"g2.2xlarge\",
    \"Placement\": {
      \"AvailabilityZone\": \"$ZONE\"
    }
  }" | jq --raw-output '.SpotInstanceRequests[0].SpotInstanceRequestId')
echo "$SPOT_INSTANCE_ID"

echo -n "Waiting for instance to be launched... "
aws ec2 wait spot-instance-request-fulfilled --spot-instance-request-ids "$SPOT_INSTANCE_ID"

INSTANCE_ID=$(aws ec2 describe-spot-instance-requests --spot-instance-request-ids "$SPOT_INSTANCE_ID" | jq --raw-output '.SpotInstanceRequests[0].InstanceId')
echo "$INSTANCE_ID"

echo -n "Removing the spot instance request... "
aws ec2 cancel-spot-instance-requests --spot-instance-request-ids "$SPOT_INSTANCE_ID" > /dev/null
echo "done"

echo -n "Waiting for instance IP... "
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"
IP=$(./ec2gaming-ip.sh)
echo "$IP"

echo -n "Waiting for server to become available... "
while ! nc -z "$IP" 3389 &> /dev/null; do sleep 5; done;
echo "up!"

if [ "$BOOTSTRAP" -eq "1" ]; then
  ./ec2gaming-rdp.sh
else
  ./ec2gaming-vpnup.sh

  echo "Starting Steam..."
  open steam://
fi
