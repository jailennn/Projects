#!/bin/bash

# Prompt user for input timestamp (format: YYYYMMDD HH:MM:SS)
echo "Enter timestamp (format: YYYYMMDD HH:MM:SS):"
read input_timestamp

# Extract the year from the input timestamp
input_year=$(date -d "$input_timestamp" +%Y)

# Convert input timestamp to Unix time (seconds since epoch)
input_time=$(date -d "$input_timestamp" +%s)

# Define the race year and TDay
race_year=2025
TDay="${race_year}0501 00:00:00"

# Convert TDay to Unix time
TDay_time=$(date -d "$TDay" +%s)
# To get the previous year
prev_year=$((race_year - 1))

# Check if the input timestamp is in the current year or the next year
if [ "$input_year" -eq "$race_year" ]; then
    # If the input timestamp is in the current race year
    not_open_start="${race_year}0601 00:00:00"   # Not Open: June 1
    super_early_start="${prev_year}1001 00:00:00" # Super Early: Oct 1
    early_start="${prev_year}1101 00:00:00"       # Early Registration: Nov 1
    registration_start="${race_year}0301 00:00:00" # Regular registration starts: Mar 1
    late_start="${race_year}0402 00:00:00"         # Late registration starts: Apr 2
    closed_start="${race_year}0502 00:00:00"       # Registration closed after TDay

elif [ "$input_year" -eq "$((race_year - 1))" ]; then
    # If the input timestamp is in the next race year
    not_open_start="${input_year}0601 00:00:00"   # Not Open: June 1
    super_early_start="${input_year}1001 00:00:00" # Super Early: Oct 1
    early_start="${input_year}1101 00:00:00"       # Early Registration: Nov 1
    registration_start="${race_year}0301 00:00:00" # Regular registration starts: Mar 1
    late_start="${race_year}0402 00:00:00"         # Late registration starts: Apr 2
    closed_start="${race_year}0502 00:00:00"       # Registration closed after TDay

else
    # If the input timestamp is outside the valid years
    echo "Timestamp is not relevant to the registration periods."
    exit 0
fi

# Convert race period dates to Unix time
not_open_time=$(date -d "$not_open_start" +%s)
super_early_time=$(date -d "$super_early_start" +%s)
early_time=$(date -d "$early_start" +%s)
registration_time=$(date -d "$registration_start" +%s)
late_time=$(date -d "$late_start" +%s)
TDay_time=$(date -d "$TDay" +%s)
closed_time=$(date -d "$closed_start" +%s)

# Determine the registration category
if [ "$input_time" -ge "$not_open_time" ] && [ "$input_time" -lt "$super_early_time" ]; then
    echo "Registration Not Open"
    echo "This registration period is not open for the year $race_year."
elif [ "$input_time" -ge "$super_early_time" ] && [ "$input_time" -lt "$early_time" ]; then
    echo "Super Early Registration"
    echo "This registration period opened on October 1 of $prev_year."
elif [ "$input_time" -ge "$early_time" ] && [ "$input_time" -lt "$registration_time" ]; then
    echo "Early Registration"
    echo "This registration period opened on November 1 of $prev_year."
elif [ "$input_time" -ge "$registration_time" ] && [ "$input_time" -lt "$late_time" ]; then
    echo "Registration"
    echo "This registration period opened on March 1 of $race_year."
elif [ "$input_time" -ge "$late_time" ] && [ "$input_time" -lt "$TDay_time" ]; then
    echo "Late Registration"
    echo "This registration period opened on April 2 of $race_year."
elif [ "$input_time" -ge "$TDay_time" ] && [ "$input_time" -lt "$closed_time" ]; then
    echo "Registration Closed"
    echo "This registration period was open until May 1 of $race_year."
else
    echo "Registration Not Open"
    echo "This registration period is not open for the year $race_year."
fi
