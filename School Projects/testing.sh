#!/bin/bash

# Source the dice_roller.sh file to use the roll_dice function
source ./dice_roller.sh

# Function to run trials and tally results
run_trials() {
    local trials=$1
    declare -A tally

    for ((i=0; i<$trials; i++)); do
        # Roll 5 dice without outputting the result
        rolled_numbers=$(roll_dice 5)

        # Tally the results
        for num in $rolled_numbers; do
            ((tally[$num]++))
        done
    done

    # Echo the tally results
    echo "Tally of rolled numbers after $trials trials:"
    for num in "${!tally[@]}"; do
        echo "$num: ${tally[$num]}"
    done
}

# Number of trials to run
num_trials=60 

# Run the trials
run_trials $num_trials
