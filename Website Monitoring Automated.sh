#!/bin/bash

WEBSITE_URL="https://www.google.com"  #targeted URL

ALERT_EMAIL="pawanugalmugale@gmail.com"    #mail

CHECK_INTERVAL=120  # In Seconds

send_email_alert() {
    echo "The website $WEBSITE_URL is down at $(date)" | mail -s "Website Down Alert" "$ALERT_EMAIL"
}

# Main monitoring loop
while true; do
    if ping -c 1 -q "$WEBSITE_URL" > /dev/null; then
        echo "Website is up."
    else
        echo "Website is down."
        send_email_alert
    fi
done

    sleep $CHECK_INTERVAL    #go to sleep for 2 minutes or 120 Seconds
done
