#!/usr/bin/env bash
set -e

aws ec2 describe-spot-price-history --instance-types g2.2xlarge --product-descriptions "Windows" --start-time "$(date +%s)" | jq --raw-output '.SpotPriceHistory[].SpotPrice' | sort | head -1
