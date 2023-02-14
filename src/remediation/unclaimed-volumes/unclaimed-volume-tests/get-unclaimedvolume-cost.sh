#!/bin/bash

# Get the response from the API and store it in a variable
Response=$(curl -s http://a06fc35aeb33f46e3bf19742538467b1-1092220675.ap-southeast-1.elb.amazonaws.com/model/assets\?window=7d)

# Filter the response to only get the data for new-pv-volume
FilteredResponse=$(echo "$Response" | jq '.data[] | .[] | select(.properties.name == "'"new-pv-volume"'")' | jq '.totalCost')

# Initialize a variable to store the sum
Sum=0

# Iterate over the filtered response and add each value to the sum
while read -r line; do
    Sum=$(echo "$Sum + $line" | bc)
done <<< "$FilteredResponse"

# Print the sum
printf "Sum: %g\n" "$Sum"
