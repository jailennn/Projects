#!/bin/bash

# Prompt for registration timestamp
read -p "Enter timestamp (format: YYYYMMDD HH:MM:SS): " timestamp

# Check registration period based on timestamp
if [[ "$timestamp" < "20241001" ]]; then
    echo "Too Early Registration"
elif [[ "$timestamp" < "20241101" ]]; then
    echo "Super Early Registration"
else
    echo "Regular Registration"
fi

# Prompt for date of birth
read -p "Enter date of birth (format: YYYYMMDD): " dob

# Extract year, month, and day of birth
dob_year=${dob:0:4}
dob_month=${dob:4:2}
dob_day=${dob:6:2}

# Race dates
race_day1="20250503"  # May 3, 2025
race_day2="20250504"  # May 4, 2025

# Function to calculate age on a given race day
calculate_age() {
    local birth_date="$1"
    local race_date="$2"
    birth_year=${birth_date:0:4}
    birth_month=${birth_date:4:2}
    birth_day=${birth_date:6:2}
    race_year=${race_date:0:4}
    race_month=${race_date:4:2}
    race_day=${race_date:6:2}

    # Calculate age
    age=$((race_year - birth_year))

    # Check if the race day is before the user's birthday
    if [[ "$race_month" -lt "$birth_month" || ( "$race_month" -eq "$birth_month" && "$race_day" -lt "$birth_day" ) ]]; then
        age=$((age - 1))
    fi

    echo $age
}

# Calculate age on race day 1 (May 3, 2025)
age_on_race_day1=$(calculate_age "$dob" "$race_day1")
echo "The runner's age on 5K/10K race day ($race_day1) will be: $age_on_race_day1 years."

# Calculate age on race day 2 (May 4, 2025)
age_on_race_day2=$(calculate_age "$dob" "$race_day2")
echo "The runner's age on full/half marathon race day ($race_day2) will be: $age_on_race_day2 years."
