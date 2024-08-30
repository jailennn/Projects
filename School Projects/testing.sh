#!/bin/bash

# source the dice_roller.sh file to use the roll_dice function
source ./dice_roller.sh

# function to run trials and tally results
run_trials() {
    local trials=$1
    declare -A tally # associative array declaration

    for ((i=0; i<$trials; i++)); do
        # roll 5 dice and store them in a variable
        rolled_numbers=$(roll_dice 5)

        # tally the results in the associative array
        for num in $rolled_numbers; do
            ((tally[$num]++))
        done
    done

    # display the tally results
    echo "Tally of rolled numbers after $trials trials:"
    for num in "${!tally[@]}"; do
        echo "$num: ${tally[$num]}"
    done
}

# specify Number of trials to run
num_trials=60 

# Run the trials
echo "Starting Test 1..."
run_trials $num_trials
