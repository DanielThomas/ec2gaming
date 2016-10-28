#!/usr/bin/env bash
source "$(dirname "$0")/ec2gaming.header"

aws ec2 describe-spot-price-history --instance-types "$INSTANCE_TYPE" --product-descriptions "Windows" --start-time `date +%s` | jq --raw-output '.SpotPriceHistory|=sort_by(.SpotPrice)|first(.SpotPriceHistory[].SpotPrice), first(.SpotPriceHistory[].AvailabilityZone)'
