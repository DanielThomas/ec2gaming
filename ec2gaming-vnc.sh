#!/usr/bin/env bash
source "$(dirname "$0")/ec2gaming.header"

USERNAME=$(head -1 ec2gaming.auth)
PASSWORD=$(tail -1 ec2gaming.auth)
open "vnc://$USERNAME:$PASSWORD@10.8.0.1"
