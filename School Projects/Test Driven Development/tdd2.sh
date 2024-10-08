#!/bin/bash

# Function to check if a year is a leap year
is_leap_year() {
    local year=$1
    if (( (year % 4 == 0 && year % 100 != 0) || year % 400 == 0 )); then
        return 0  # True (leap year)
    else
        return 1  # False (not a leap year)
    fi
}

# Function to remove leading zeros
strip_leading_zero() {
    echo "$1" | sed 's/^0*//'
}

# Prompt user for input timestamp (format: YYYYMMDD HH:MM:SS)
echo "Enter timestamp (format: YYYYMMDD HH:MM:SS):"
read input_timestamp

# Extract the year, month, and day from the input timestamp
input_year=$(date -d "$input_timestamp" +%Y)
input_month=$(date -d "$input_timestamp" +%m)
input_day=$(date -d "$input_timestamp" +%d)

# Strip leading zeros from month and day
input_month=$(strip_leading_zero "$input_month")
input_day=$(strip_leading_zero "$input_day")

# Convert input timestamp to Unix time (seconds since epoch)
input_time=$(date -d "$input_timestamp" +%s 2>/dev/null)

# Check if the date is valid
if [ -z "$input_time" ]; then
    echo "Invalid date format or non-existent date."
    exit 1
fi

# Define the race year and TDay
race_year=2025
TDay="${race_year}0501 23:59:59"  # Include the full day for TDay

# Convert TDay to Unix time
TDay_time=$(date -d "$TDay" +%s)

# To get the previous year
prev_year=$((race_year - 1))

# Check if the input timestamp is in the current year or the previous year
if [ "$input_year" -eq "$race_year" ] || [ "$input_year" -eq "$prev_year" ]; then
    # Define early registration end date based on leap year check
    if is_leap_year "$race_year"; then
        early_end="${race_year}0229 23:59:59"  # Leap year: Feb 29
    else
        early_end="${race_year}0228 23:59:59"  # Non-leap year: Feb 28
    fi

    not_open_start="${race_year}0601 00:00:00"   # Not Open: June 1
    super_early_start="${prev_year}1001 00:00:00" # Super Early: Oct 1 of previous year
    early_start="${prev_year}1101 00:00:00"       # Early Registration: Nov 1 of previous year
    registration_start="${race_year}0301 00:00:00" # Regular registration starts: Mar 1 of race year
    late_start="${race_year}0402 00:00:00"         # Late registration starts: Apr 2 of race year
    closed_start="${race_year}0501 23:59:59"       # Registration closed after TDay

else
    # If the input timestamp is outside the valid years
    echo "Timestamp is not relevant to the registration periods."
    exit 0
fi

# Convert race period dates to Unix time
not_open_time=$(date -d "$not_open_start" +%s)
super_early_time=$(date -d "$super_early_start" +%s)
early_time=$(date -d "$early_start" +%s)
early_end_time=$(date -d "$early_end" +%s)
registration_time=$(date -d "$registration_start" +%s)
late_time=$(date -d "$late_start" +%s)
TDay_time=$(date -d "$TDay" +%s)
closed_time=$(date -d "$closed_start" +%s)

# Determine the registration category
if [ "$input_time" -ge "$not_open_time" ]; then
    echo "Registration Not Open"
    echo "This registration period is not open for the year $race_year."
elif [ "$input_time" -ge "$super_early_time" ] && [ "$input_time" -lt "$early_time" ]; then
    echo "Super Early Registration"
    echo "This registration period opened on October 1 of $prev_year."
elif [ "$input_time" -ge "$early_time" ] && [ "$input_time" -le "$early_end_time" ]; then
    echo "Early Registration"
    echo "This registration period opened on November 1 of $prev_year and ends on $early_end."
elif [ "$input_time" -ge "$registration_time" ] && [ "$input_time" -lt "$late_time" ]; then
    echo "Registration"
    echo "This registration period opened on March 1 of $race_year."
elif [ "$input_time" -ge "$late_time" ] && [ "$input_time" -le "$TDay_time" ]; then
    echo "Late Registration"
    echo "This registration period opened on April 2 of $race_year."
elif [ "$input_time" -gt "$TDay_time" ]; then
    echo "Registration Closed"
    echo "This registration period was open until May 1 of $race_year."
else
    echo "Registration Not Open"
    echo "This registration period is not open for the year $race_year."
fi
