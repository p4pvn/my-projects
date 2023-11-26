#!/bin/bash

WEBSITE_URL="https://www.google.com"  #targeted URL

ALERT_EMAIL="pawanugalmugale@gmail.com"    #storing mail in variable

CHECK_INTERVAL=120  # check interval in Seconds

send_email_alert() {                #creating function of mail send
    echo "The website $WEBSITE_URL is down at $(date)" | mail -s "Website Down Alert" "$ALERT_EMAIL"
}

# Main monitoring loop
while true; do
    if ping -c 1 "$WEBSITE_URL" > /dev/null; then
        echo "Webserver is up and running."
    else
        echo "Website is down."
        send_email_alert
    fi
done

    sleep $CHECK_INTERVAL    #go to sleep for 2 minutes or 120 Seconds
done
