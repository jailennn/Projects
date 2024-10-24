#!/bin/bash

# Set Thanksgiving Day and input date
TDay="20241028"
TDay_time=$(date -d "$TDay" +%s)
read -p "Enter today's date in the format YYYYMMDD: " input_date
input_time=$(date -d "$input_date" +%s)

# Price calculation based on registration time
calculate_price() {
    local time_input="$1"
    local race_type="$2"
    
    if [ "$time_input" -lt $(date -d "20240201" +%s) ]; then
        price_tier="Super Early"
    elif [ "$time_input" -lt $(date -d "20240601" +%s) ]; then
        price_tier="Early"
    elif [ "$time_input" -lt $(date -d "20241001" +%s) ]; then
        price_tier="Baseline"
    elif [ "$time_input" -le "$TDay_time" ]; then
        price_tier="Late"
    else
        echo "Registration Not Open"
        return
    fi
    
    # Assign prices based on race type
    case "$race_type" in
        "5K")
            case "$price_tier" in
                "Super Early") echo "20.00" ;;
                "Early") echo "25.00" ;;
                "Baseline") echo "30.00" ;;
                "Late") echo "35.00" ;;
            esac
            ;;
        "10K")
            case "$price_tier" in
                "Super Early") echo "30.00" ;;
                "Early") echo "35.00" ;;
                "Baseline") echo "40.00" ;;
                "Late") echo "45.00" ;;
            esac
            ;;
        "Half Marathon")
            case "$price_tier" in
                "Super Early") echo "40.00" ;;
                "Early") echo "50.00" ;;
                "Baseline") echo "60.00" ;;
                "Late") echo "70.00" ;;
            esac
            ;;
        "Full Marathon")
            case "$price_tier" in
                "Super Early") echo "50.00" ;;
                "Early") echo "60.00" ;;
                "Baseline") echo "70.00" ;;
                "Late") echo "80.00" ;;
            esac
            ;;
        *)
            echo "Invalid race type."
            ;;
    esac
}

# Function to calculate age
calculate_age() {
    local dob="$1"
    local event_date="$2"
    local birth_time=$(date -d "$dob" +%s)
    local event_time=$(date -d "$event_date" +%s)
    local age=$(( (event_time - birth_time) / (365*24*60*60) ))
    echo "$age"
}

# Only allow registration if input date is valid
if [ "$input_time" ] && [ "$input_time" -lt "$TDay_time" ]; then
    # Prompt the user for personal information
    echo "Enter your first name:"
    read first_name
    echo "Enter your last name:"
    read last_name
    echo "Enter your date of birth (format: YYYYMMDD):"
    read dob
    echo "Enter your gender (M/F):"
    read gender
    echo "Enter your email address:"
    read email_address

    # Calculate age for 5K/10K participants
    age_5k_10k=$(calculate_age "$dob" "$TDay")
    
    # Prompt the user for up to two race types
    echo "Enter race type 1 (5K, 10K, Half Marathon, Full Marathon):"
    read race_type1

    echo "Would you like to register for a second race? (y/n):"
    read second_race
    if [ "$second_race" == "y" ]; then
        echo "Enter race type 2 (5K, 10K, Half Marathon, Full Marathon):"
        read race_type2
    else
        race_type2=""
    fi

    # Calculate prices for each race type
    price1=$(calculate_price "$input_time" "$race_type1")
    price2=""
    if [ -n "$race_type2" ]; then
        price2=$(calculate_price "$input_time" "$race_type2")
    fi

    # Write to the appropriate roster files
    roster_directory="$HOME"
    
    k_race_files=("5K_Roster.csv" "10K_Roster.csv")
    marathon_files=("Half_Marathon_Roster.csv" "Full_Marathon_Roster.csv")

    # Function to write to roster
    write_to_roster() {
        local race_type=$1
        local price=$2
        
        case "$race_type" in
            "5K")
                roster_file="${roster_directory}/${k_race_files[0]}"
                ;;
            "10K")
                roster_file="${roster_directory}/${k_race_files[1]}"
                ;;
            "Half Marathon")
                roster_file="${roster_directory}/${marathon_files[0]}"
                ;;
            "Full Marathon")
                roster_file="${roster_directory}/${marathon_files[1]}"
                ;;
            *)
                echo "Invalid race type."
                return
                ;;
        esac
        
        if [ "$price" != "Registration Not Open" ]; then
            echo "$first_name,$last_name,$age_5k_10k,$gender,$email_address,$price" >> "$roster_file"
            echo "You have successfully registered for the $race_type race!"
            echo "Registration details saved in: $roster_file"
        else
            echo "You cannot register for the $race_type race at this time."
        fi
    }

    # Register for first race
    write_to_roster "$race_type1" "$price1"

    # Register for second race, if applicable
    if [ -n "$race_type2" ]; then
        write_to_roster "$race_type2" "$price2"
    fi
else
    echo "You cannot register at this time."
fi
