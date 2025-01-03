#!/bin/bash

# Declaring Variables:
get_active_users() {
    # Extracting the number of active users using uptime
    uptime | awk '{print $NF}' | sed 's/,//'
}

# Main Script
while true; do
    # Recalculate ACTIVE_USERS in each iteration
    ACTIVE_USERS=$(get_active_users)

    echo "Current active users: $ACTIVE_USERS"

    # Check if there are no active users
    if [ "$ACTIVE_USERS" -eq 0 ]; then
        echo "Shutting down since there are no active users."
        echo "ACTIVE USERS ARE $ACTIVE_USERS"
        # Schedule a shutdown after 15 minutes
        shutdown +15
        exit 0  # Exit the script after scheduling shutdown
    fi

    # Sleep to prevent excessive CPU usage
    sleep 600
done
