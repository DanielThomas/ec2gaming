#!/usr/bin/env bash
source "$(dirname "$0")/ec2gaming.header"

USER=$(head -1 ec2gaming.auth)
PASSWD=$(tail -1 ec2gaming.auth)
open "vnc://$USER:$PASSWD@10.8.0.1"
