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

# Function to find the first Thursday of May for a given year
get_first_thursday_of_may() {
    local year=$1
    local may_first="${year}0501"
    local weekday=$(date -d "$may_first" +%w)
    if [ "$weekday" -le 4 ]; then
        local offset=$((4 - weekday))
    else
        local offset=$((7 - weekday + 4))
    fi
    first_thursday=$(date -d "$may_first +$offset days" +"%Y%m%d")
    echo "$first_thursday"
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

    dob_month=$(strip_leading_zero "$dob_month")
    dob_day=$(strip_leading_zero "$dob_day")
    race_month=$(strip_leading_zero "$race_month")
    race_day_num=$(strip_leading_zero "$race_day_num")

    local age=$(( race_year - dob_year ))
    if (( race_month < dob_month )) || (( race_month == dob_month && race_day_num < dob_day )); then
        age=$((age - 1))
    fi

    echo "$age"
}

# Prompt user for input timestamp (format: YYYYMMDD HH:MM:SS)
echo "Enter timestamp (format: YYYYMMDD HH:MM:SS):"
read input_timestamp

input_year=$(date -d "$input_timestamp" +%Y)
input_month=$(date -d "$input_timestamp" +%m)
input_day=$(strip_leading_zero $(date -d "$input_timestamp" +%d))

input_time=$(date -d "$input_timestamp" +%s 2>/dev/null)

if [ -z "$input_time" ]; then
    echo "Invalid date format or non-existent date."
    exit 1
fi

if [ "$input_month" -ge 10 ]; then
    race_year=$((input_year + 1))
else
    race_year=$input_year
fi

TDay=$(get_first_thursday_of_may "$race_year")
TDay="${TDay} 23:59:59"

TDay_time=$(date -d "$TDay" +%s)
prev_year=$((race_year - 1))

if [ "$input_year" -eq "$race_year" ] || [ "$input_year" -eq "$prev_year" ]; then
    if is_leap_year "$race_year"; then
        early_end="${race_year}0229 23:59:59"
    else
        early_end="${race_year}0228 23:59:59"
    fi
    not_open_start="${race_year}0601 00:00:00"
    super_early_start="${prev_year}1001 00:00:00"
    early_start="${prev_year}1101 00:00:00"
    registration_start="${race_year}0301 00:00:00"
    late_start="${race_year}0402 00:00:00"
    closed_start="$TDay"
else
    echo "Timestamp is not relevant to the registration periods."
    exit 0
fi

not_open_time=$(date -d "$not_open_start" +%s)
super_early_time=$(date -d "$super_early_start" +%s)
early_time=$(date -d "$early_start" +%s)
early_end_time=$(date -d "$early_end" +%s)
registration_time=$(date -d "$registration_start" +%s)
late_time=$(date -d "$late_start" +%s)
closed_time=$(date -d "$closed_start" +%s)

# Determine the registration phase and prices
registration_phase="Not Open"
k_race_price=0
ten_k_price=0
marathon_price=0
full_marathon_price=0

if [ "$input_time" -ge "$not_open_time" ]; then
    registration_phase="Registration Not Open"
elif [ "$input_time" -ge "$super_early_time" ] && [ "$input_time" -lt "$early_time" ]; then
    registration_phase="Super Early Registration"
    k_race_price=30          # 5K price
    ten_k_price=50          # 10K price
    marathon_price=65        # Half Marathon price
    full_marathon_price=75   # Full Marathon price
elif [ "$input_time" -ge "$early_time" ] && [ "$input_time" -le "$early_end_time" ]; then
    registration_phase="Early Registration"
    k_race_price=40          # 5K price
    ten_k_price=55          # 10K price
    marathon_price=70        # Half Marathon price
    full_marathon_price=80   # Full Marathon price
elif [ "$input_time" -ge "$registration_time" ] && [ "$input_time" -lt "$late_time" ]; then
    registration_phase="Baseline Registration"
    k_race_price=50          # 5K price
    ten_k_price=70          # 10K price
    marathon_price=85        # Half Marathon price
    full_marathon_price=85   # Full Marathon price
elif [ "$input_time" -ge "$late_time" ] && [ "$input_time" -le "$TDay_time" ]; then
    registration_phase="Late Registration"
    k_race_price=64          # 5K price
    ten_k_price=89          # 10K price
    marathon_price=99        # Half Marathon price
    full_marathon_price=109  # Full Marathon price
elif [ "$input_time" -gt "$TDay_time" ]; then
    registration_phase="Registration Closed"
fi

echo "$registration_phase"

# Prompt for user details
echo "Enter date of birth (format: YYYYMMDD):"
read dob
dob_time=$(date -d "$dob" +%s 2>/dev/null)
if [ -z "$dob_time" ]; then
    echo "Invalid date of birth format or non-existent date."
    exit 1
fi

race_day_5k_10k=$(date -d "$(echo $TDay | cut -d' ' -f1) + 2 days" +%Y%m%d)
race_day_full_half=$(date -d "$(echo $TDay | cut -d' ' -f1) + 3 days" +%Y%m%d)

age_5k_10k=$(calculate_age "$dob" "$race_day_5k_10k")
age_full_half=$(calculate_age "$dob" "$race_day_full_half")

echo "The runner's age on 5K/10K race day ($race_day_5k_10k) will be: $age_5k_10k years."
echo "The runner's age on full/half marathon race day ($race_day_full_half) will be: $age_full_half years."

# Collect additional user information for the race roster
echo "Enter your first name:"
read first_name

echo "Enter your last name:"
read last_name

echo "Enter your gender:"
read gender

echo "Enter your email address:"
read email_address

# Define the path for the race roster files
roster_directory="$HOME"

# Create roster files
k_race_files=("5K_Roster.csv" "10K_Roster.csv")
marathon_files=("Half_Marathon_Roster.csv" "Full_Marathon_Roster.csv")

# Create headers for the rosters if they don't exist
for file in "${k_race_files[@]}" "${marathon_files[@]}"; do
    full_path="$roster_directory/$file"
    if [ ! -f "$full_path" ]; then
        echo "Creating race roster for $full_path."
        echo "First Name,Last Name,Gender,Email,Age,Timestamp,Price" > "$full_path"
    fi
done

# Race Selection: Users can select one K race and one marathon
selected_k_race=""
selected_marathon=""
total_price=0  # Initialize total price

# Loop until valid selections are made
while true; do
    echo "Select your race(s):"
    echo "1) 5K"
    echo "2) 10K"
    echo "3) Half Marathon"
    echo "4) Full Marathon"
    echo "5) Finish registration"

    read choice

    case $choice in
        1)
            selected_k_race="5K"
            total_price=$((total_price + k_race_price))
            echo "You selected the 5K race. Price: \$$k_race_price"
            ;;
        2)
            selected_k_race="10K"
            total_price=$((total_price + ten_k_price))
            echo "You selected the 10K race. Price: \$$ten_k_price"
            ;;
        3)
            selected_marathon="Half Marathon"
            total_price=$((total_price + marathon_price))
            echo "You selected the Half Marathon. Price: \$$marathon_price"
            ;;
        4)
            selected_marathon="Full Marathon"
            total_price=$((total_price + full_marathon_price))
            echo "You selected the Full Marathon. Price: \$$full_marathon_price"
            ;;
        5)
            break
            ;;
        *)
            echo "Invalid choice. Please select again."
            continue
            ;;
    esac
done

# Output registration summary
echo "Registration Summary:"
echo "Name: $first_name $last_name"
echo "Gender: $gender"
echo "Email: $email_address"
echo "Age on 5K/10K Race Day: $age_5k_10k years"
echo "Age on Half/Full Marathon Race Day: $age_full_half years"
echo "Selected K Race: $selected_k_race"
echo "Selected Marathon: $selected_marathon"
echo "Total Price: \$$total_price"

# Save the registration details to the appropriate race roster
if [ -n "$selected_k_race" ]; then
    echo "$first_name,$last_name,$gender,$email_address,$age_5k_10k,$input_timestamp,$total_price" >> "$roster_directory/${selected_k_race}_Roster.csv"
fi

if [ -n "$selected_marathon" ]; then
    echo "$first_name,$last_name,$gender,$email_address,$age_full_half,$input_timestamp,$total_price" >> "$roster_directory/${selected_marathon// /_}_Roster.csv"
fi

echo "Registration complete! Thank you for signing up."
