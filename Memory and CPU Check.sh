#!/bin/bash

# Set the thresholds for CPU and memory usage (in percentage)
CPU_THRESHOLD=80        # Declaring variables and Assigning values
MEMORY_THRESHOLD=80     # Declaring variables and Assigning values

# Function to check CPU usage
check_cpu_usage() {
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)    #converting o/p in batch mode to stop continous flow of information.
    if [[ "$CPU_USAGE" -ge "$CPU_THRESHOLD" ]]; then
        echo "High CPU usage detected: $CPU_USAGE%" | mail -s "Alert: CPU" pawanugalmugale@gmail.com    # usage is greater than 80%
    fi
}

# Function to check memory usage
check_memory_usage() {
    MEMORY_USAGE=$(free | grep "Mem" | awk '{print $3/$2 * 100.0}' | tr ',' '.')  #o/p is showing in commas so traslating it to make decimals
    if [[ "$MEMORY_USAGE" -ge "$MEMORY_THRESHOLD" ]]; then
        echo "High memory usage detected: $MEMORY_USAGE%" | mail -s "Alert: Memory" pawanugalmugale@gmail.com
    fi
}

while true; do
    check_cpu_usage
    check_memory_usage
    sleep 60  # It will sleep for 60 seconds once checked and will check again after 60 seconds.
done
