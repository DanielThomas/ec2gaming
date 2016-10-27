#!/usr/bin/env bash
set -e

USER=$(head -1 ec2gaming.auth)
PASSWD=$(tail -1 ec2gaming.auth)
open "vnc://$USER:$PASSWD@10.8.0.1"
