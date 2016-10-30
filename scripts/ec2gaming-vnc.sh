#!/usr/bin/env bash
source "$(dirname "$0")/ec2gaming.header"

open "vnc://$USERNAME:$PASSWORD@10.8.0.1"
