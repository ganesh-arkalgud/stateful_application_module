#!/bin/bash

set -Exeuo pipefail

DEVICE_NAME=${device_name}
VOLUME_ID=${volume_id}
ASG_HOOK_NAME=${asg_hook_name}
ASG_NAME=${asg_name}
ENI_ID=${interface_id}
REGION=${aws_region}

# get instance Id
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/instance-id)

# Attach the ENI
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/best-practices-for-configuring-network-interfaces.html
# A warm or hot attach of an additional network interface might require you to manually bring up the second interface,
# configure the private IPv4 address, and modify the route table accordingly.
# Instances running Amazon Linux or Windows Server automatically recognize the warm or hot attach and configure themselves.

aws ec2 attach-network-interface --device-index 1 --instance-id "$INSTANCE_ID" --network-interface-id "$ENI_ID" --region "$REGION"

# Attach volume
aws ec2 attach-volume --device "$DEVICE_NAME" --instance-id "$INSTANCE_ID" --volume-id "$VOLUME_ID" --region "$REGION"

# Mount volume

# Install required software.
echo "Installing required software"

# Update AWS ASG hook status to proceed.
aws autoscaling complete-lifecycle-action --lifecycle-action-result CONTINUE \
  --instance-id "$INSTANCE_ID" --lifecycle-hook-name "$ASG_HOOK_NAME" \
  --auto-scaling-group-name "$ASG_NAME" --region "$REGION"