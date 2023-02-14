#!/bin/bash

unclaimed_pv=""

# This function get_unclaimed_volume is used to retrieve the list of unclaimed Persistent Volumes in a Kubernetes cluster using the Kubecost API
get_unclaimed_volume() {
    # Define the API endpoint of Kubecost for Persistent volumes
    endpoint="http://a06fc35aeb33f46e3bf19742538467b1-1092220675.ap-southeast-1.elb.amazonaws.com/model/allPersistentVolumes"

    # Make a GET request to the API using curl
    response=$(curl -s "$endpoint")

    # Parse the response to get the list of all volumes
    pv_names=$(echo "$response" | jq '.items[].metadata.name')

    # Gets statuses of all available volumes
    pv_statuses=$(echo "$response" | jq '.items[].status.phase')

    # Iterate over the list of statuses and get the name of those pv's whose status is available

    for i in $(echo "$pv_statuses" | grep -n "Available"); do
        line_num=$(echo "$i" | cut -d: -f1)
        name=$(echo "$pv_names" | sed -n "${line_num}p")
        unclaimed_pv=${name//\"/}
    done

}

# This function trigger_robusta_action is used to trigger a delete action on an unclaimed Persistent Volume in a Kubernetes cluster using the Robusta API
trigger_robusta_action() {
    # Trigger robusta action to delete unclaimed volume
    result=$(curl -X POST http://robusta-runner.robusta.svc.cluster.local/api/trigger -H 'Content-Type: application/json' -d '{"action_name": "delete_persistent_volume", "action_params": {"name": "'"$unclaimed_pv"'"}}' 2>/dev/null | head -n 1)

    # Check the response of the delete action
    if echo "$result" | grep -q '"success":true'; then
        echo "Unclaimed PV $unclaimed_pv deleted successfully"
        unclaimed_pv=""
    else
        echo "PV not deleted"
    fi
}

# Verify the deletion of PV through Kubecost API
verify_deletion() {
    # Get unclaimed volume from kubecost
    get_unclaimed_volume
    if [ -z "$unclaimed_pv" ]; then
        echo "Identified unclaimed PV was deleted and verified through Kubecost API"
    else
        echo "PV was not deleted from the cluster"
    fi
}

get_unclaimed_volume
trigger_robusta_action
verify_deletion
