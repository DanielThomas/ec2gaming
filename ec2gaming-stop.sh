#!/usr/bin/env bash
source "$(dirname "$0")/ec2gaming.header"

./ec2gaming-vpndown.sh
./ec2gaming-terminate.sh
