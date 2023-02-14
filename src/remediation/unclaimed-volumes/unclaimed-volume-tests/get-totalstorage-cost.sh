#!/bin/bash

# Script that gets the Total Cost of Storage.

# Make curl request and extract totalCost using jq
total_cost=$(curl -s "http://a06fc35aeb33f46e3bf19742538467b1-1092220675.ap-southeast-1.elb.amazonaws.com/model/assets?window=7d&aggregate=type&accumulate=true" | jq -r '.data[].Disk.totalCost')

# Print the result
echo "Total Storage Cost: $total_cost"

