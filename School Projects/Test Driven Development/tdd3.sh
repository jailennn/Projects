#!/bin/bash

# Filepath for the race roster CSV
race_roster_file=~/race_roster.csv

# Function to check if a year is a leap year
is_leap_year() {
    local year=$1
    if (( (year % 4 == 0 && year % 100 != 0) || year % 400 == 0 )); then
        return 0  # True (leap year)
    else
        return 1  # False (not a leap year)
    fi
}

# Function to calculate age based on date of birth and a given date
calculate_age() {
    local dob=$1
    local race_day=$2
    local dob_year=$(echo "$dob" | cut -c1-4)
    local dob_month=$(echo "$dob" | cut -c5-6)
    local dob_day=$(echo "$dob" | cut -c7-8)

    local race_year=$(echo "$race_day" | cut -c1-4)
    local race_month=$(echo "$race_day" | cut -c5-6)
    local race_day_num=$(echo "$race_day" | cut -c7-8)

    # Calculate the age on race day
    local age=$(( race_year - dob_year ))

    # Adjust age if the birthday hasn't occurred yet in the race year
    if (( race_month < dob_month )) || (( race_month == dob_month && race_day_num < dob_day )); then
        age=$((age - 1))
    fi

    echo "$age"
}

# Function to find the first Thursday of May for a given year
get_first_thursday_of_may() {
    local year=$1
    # Start at May 1st of the given year
    local may_first="${year}0501"
    # Find the weekday of May 1st (0 = Sunday, 6 = Saturday)
    local weekday=$(date -d "$may_first" +%w)
    
    # Calculate how many days to add to reach the first Thursday (weekday = 4)
    if [ "$weekday" -le 4 ]; then
        local offset=$((4 - weekday))
    else
        local offset=$((7 - weekday + 4))
    fi
    
    # Calculate the first Thursday of May
    first_thursday=$(date -d "$may_first +$offset days" +"%Y%m%d")
    echo "$first_thursday"
}

# Prompt the user for registration details
echo "Enter First Name:"
read first_name
echo "Enter Last Name:"
read last_name
echo "Enter Date of Birth (format: YYYYMMDD):"
read dob
echo "Enter Gender:"
read gender
echo "Enter Email Address:"
read email

# Automatically generate the registration timestamp (current date and time)
registration_timestamp=$(date +"%Y%m%d %H:%M:%S")

# Determine the race year dynamically based on the current date
current_year=$(date +%Y)
current_month=$(date +%m)

# Calculate race year based on the current date
if [ "$current_month" -ge 10 ]; then
    # If the month is October or later, race year is the next year
    race_year=$((current_year + 1))
else
    # Otherwise, race year is the current year
    race_year=$current_year
fi

# Get TDay (first Thursday of May for the determined race year)
TDay=$(get_first_thursday_of_may "$race_year")

# Calculate the race days: Saturday (TDay + 2) and Sunday (TDay + 3)
race_day_5k_10k=$(date -d "$TDay + 2 days" +%Y%m%d)
race_day_full_half=$(date -d "$TDay + 3 days" +%Y%m%d)

# Calculate the runner's age on race days
age_5k_10k=$(calculate_age "$dob" "$race_day_5k_10k")
age_full_half=$(calculate_age "$dob" "$race_day_full_half")

# Check if the race roster file exists, if not, create it with headers
if [ ! -f "$race_roster_file" ]; then
    echo "First Name,Last Name,Age on 5K/10K Day,Age on Full/Half Marathon Day,Gender,Email Address,Registration Timestamp" > "$race_roster_file"
fi

# Append the runner's data to the race roster CSV
echo "$first_name,$last_name,$age_5k_10k,$age_full_half,$gender,$email,$registration_timestamp" >> "$race_roster_file"

# Confirm the runner was added
echo "Runner successfully added to the race roster."
