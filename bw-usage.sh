#!/bin/bash
clear
current_date=$(date +"%Y-%m-%d")
daily_data=$(vnstat -i eth0 --oneline | grep "$current_date")
if [ -n "$daily_data" ]; then
  daily_received=$(echo "$daily_data" | awk -F';' '{print $4}')
  daily_sent=$(echo "$daily_data" | awk -F';' '{print $5}')
  daily_total=$(echo "$daily_data" | awk -F';' '{print $6}')
else
  echo "No data available for daily usage on $current_date"
  exit 1
fi
current_month=$(date +"%Y-%m")
monthly_data=$(vnstat -i eth0 --oneline | grep "$current_month")
if [ -n "$monthly_data" ]; then
  monthly_received=$(echo "$monthly_data" | awk -F';' '{print $9}')
  monthly_sent=$(echo "$monthly_data" | awk -F';' '{print $10}')
  monthly_total=$(echo "$monthly_data" | awk -F';' '{print $11}')
else
  echo "No data available for monthly usage in $current_month"
  exit 1
fi
# Output in evenly spaced ASCII bandwidth box
echo "┌───────────────────────────────────────────────┐"
echo "│             Daily Bandwidth Usage             │"
echo "├───────────────┬───────────────┬───────────────┤"
echo "│   Received    │      Sent     │     Total     │"
echo "├───────────────┼───────────────┼───────────────┤"
printf "│%-14s │%-14s │%-14s │\n" "$daily_received" "$daily_sent" "$daily_total"
echo "└───────────────┴───────────────┴───────────────┘"

echo "┌───────────────────────────────────────────────┐"
echo "│            Monthly Bandwidth Usage            │"
echo "├───────────────┬───────────────┬───────────────┤"
echo "│   Received    │      Sent     │     Total     │"
echo "├───────────────┼───────────────┼───────────────┤"
printf "│%-14s │%-14s │%-14s │\n" "$monthly_received" "$monthly_sent" "$monthly_total"
echo "└───────────────┴───────────────┴───────────────┘"