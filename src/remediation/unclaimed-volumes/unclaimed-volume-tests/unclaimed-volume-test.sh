#!/bin/bash

# Copyright (c) 2023, Xgrid Inc, https://xgrid.co

# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

# http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

unclaimedPv=""

# This function get_unclaimed_volume is used to retrieve the list of unclaimed Persistent Volumes in a Kubernetes cluster using the Kubecost API
get_unclaimed_volume() {
    # Define the API endpoint of Kubecost for Persistent volumes
    endpoint="http://kubecost-cost-analyzer.kubecost.svc.cluster.local:9003/allPersistentVolumes"

    # Make a GET request to the API using curl
    response=$(curl -s "$endpoint")

    # Parse the response to get the list of all volumes
    pvNames=$(echo "$response" | jq '.items[].metadata.name')

    # Gets statuses of all available volumes
    pvStatuses=$(echo "$response" | jq '.items[].status.phase')

    # Iterate over the list of statuses and get the name of those pv's whose status is available

    for i in $(echo "$pvStatuses" | grep -n "Available"); do
        lineNum=$(echo "$i" | cut -d: -f1)
        name=$(echo "$pvNames" | sed -n "${lineNum}p")
        unclaimedPv=${name//\"/}
    done

}

# This function trigger_robusta_action is used to trigger a delete action on an unclaimed Persistent Volume in a Kubernetes cluster using the Robusta API
trigger_robusta_action() {
    # Trigger robusta action to delete unclaimed volume
    result=$(curl -X POST http://robusta-runner.robusta.svc.cluster.local/api/trigger -H 'Content-Type: application/json' -d '{"action_name": "delete_persistent_volume", "action_params": {"name": "'"$unclaimedPv"'"}}' 2>/dev/null | head -n 1)

    # Check the response of the delete action if the response is success, it means pv is deleted successfully.
    # We use this check to confirm if volume is deleted successfully
    if echo "$result" | grep -q '"success":true'; then
        echo "Unclaimed PV $unclaimedPv deleted successfully"
    else
        echo "PV not deleted"
        exit 1
    fi
}

# Verify the deletion of PV through Kubecost API
# This function verifies the deleted volume. It stores already retireved volume in a separate variable and then gets pvs data through get_unclaimed_volume function
verify_deletion() {
    # We store already retrieved pv name in a variable to compare later
    oldPv=$unclaimedPv
    unclaimedPv=""
    # Get unclaimed volume from kubecost
    get_unclaimed_volume

    if [[ "$oldPv" == "$unclaimedPv" ]]; then
        echo "Volume $oldPv is not deleted"
        exit 1
    else
        echo "PV deleted and confirmed"
    fi
}

get_unclaimed_volume
trigger_robusta_action
verify_deletion
