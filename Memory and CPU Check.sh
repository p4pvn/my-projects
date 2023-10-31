#!/bin/bash

# Set the thresholds for CPU and memory usage (in percentage)
CPU_THRESHOLD=80        # Declaring variables and Assigning values
MEMORY_THRESHOLD=80     # Declaring variables and Assigning values

# Function to check CPU usage
check_cpu_usage() {
    CPU_USAGE=$(top | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)
    if [ "$CPU_USAGE" -ge "$CPU_THRESHOLD" ]; then
        echo "High CPU usage detected: $CPU_USAGE%"
        # You can add alert/notification mechanisms here, like sending an email or displaying a message.
    fi
}

# Function to check memory usage
check_memory_usage() {
    MEMORY_USAGE=$(free | grep "Mem" | awk '{print $3/$2 * 100.0}')
    if [ "$MEMORY_USAGE" -ge "$MEMORY_THRESHOLD" ]; then
        echo "High memory usage detected: $MEMORY_USAGE%"
        # You can add alert/notification mechanisms here, like sending an email or displaying a message.
    fi
}

while true; do
    check_cpu_usage
    check_memory_usage
    sleep 60  # It will sleep for 60 seconds once checked and will check again after 60 seconds.
done
