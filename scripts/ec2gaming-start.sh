#!/bin/bash
source "$(dirname "$0")/ec2gaming.header"

BOOTSTRAP=0

echo -n "Getting lowest $INSTANCE_TYPE bid... "
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

echo -n "Looking for S3 bucket... "
ACCOUNT_ID=$(aws iam get-user | jq '.User.Arn' | cut -d ':' -f 5)
BUCKET="ec2gaming-$ACCOUNT_ID"
if ! aws s3api head-bucket --bucket "$BUCKET" &> /dev/null; then
  echo -n "not found. Creating... "
  REGION=$(aws configure get region)
  aws s3api create-bucket --bucket "$BUCKET" --region "$REGION" --create-bucket-configuration LocationConstraint="$REGION" > /dev/null
fi
sed "s/BUCKET/$BUCKET/g;s/USERNAME/$USERNAME/g;s/PASSWORD/$PASSWORD/g" ec2gaming.bat.template > ../ec2gaming.bat
echo "$BUCKET"

PROFILE_NAME="ec2gaming"
echo -n "Looking for instance profile... "
if ! aws iam get-instance-profile --instance-profile-name ec2gaming &> /dev/null; then
  echo -n "not found. Creating... "
  aws iam create-role --role-name "$PROFILE_NAME" --assume-role-policy-document file://ec2gaming-trustpolicy.json > /dev/null
  sed "s/BUCKET/$BUCKET/g" ec2gaming-permissionpolicy.json.template > ec2gaming-permissionpolicy.json
  aws iam put-role-policy --role-name "$PROFILE_NAME" --policy-name "$PROFILE_NAME" --policy-document file://ec2gaming-permissionpolicy.json > /dev/null
  aws iam create-instance-profile --instance-profile-name "$PROFILE_NAME"  > /dev/null
  aws iam add-role-to-instance-profile --instance-profile-name "$PROFILE_NAME" --role-name "$PROFILE_NAME" > /dev/null
fi
INSTANCE_PROFILE_ARN=$(aws iam get-instance-profile --instance-profile-name ec2gaming | jq -r '.InstanceProfile.Arn')
echo "$INSTANCE_PROFILE_ARN"

echo -n "Creating spot instance request... "
SPOT_INSTANCE_ID=$(aws ec2 request-spot-instances --spot-price "$FINAL_SPOT_PRICE" --launch-specification "
  {
    \"SecurityGroupIds\": [\"$EC2_SECURITY_GROUP_ID\"],
    \"ImageId\": \"$AMI_ID\",
    \"InstanceType\": \"$INSTANCE_TYPE\",
    \"Placement\": {
      \"AvailabilityZone\": \"$ZONE\"
    },
    \"IamInstanceProfile\": {
      \"Arn\": \"$INSTANCE_PROFILE_ARN\"
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
