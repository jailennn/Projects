#!/bin/bash

# Test script for checking permutation matching logic between dice rolls

# Function to simulate rolling dice
roll_dice() {
    local num_dice=$1
    rolled=()
    for ((i=0; i<num_dice; i++)); do
        rolled+=($((RANDOM % 6 + 1)))
    done
    echo "${rolled[@]}"
}

# Main function to test the permutation matching logic
test_permutations() {
    local trials=$1
    local num_dice=$2
    declare -i repeat_count=0
    declare -a prev_roll=()

    echo "Running $trials trials with $num_dice dice..."

    for ((i=0; i<$trials; i++)); do
        # Roll dice
        rolled_numbers=($(roll_dice $num_dice))

        # Check if this is not the first roll
        if [ ${#prev_roll[@]} -gt 0 ]; then
            # Sort both the current and previous roll to check for permutation match
            sorted_current=($(echo "${rolled_numbers[@]}" | tr ' ' '\n' | sort -n))
            sorted_previous=($(echo "${prev_roll[@]}" | tr ' ' '\n' | sort -n))

            # Compare the sorted arrays
            if [[ "${sorted_current[@]}" == "${sorted_previous[@]}" ]]; then
                ((repeat_count++))
            fi
        fi

        # Store current roll as the previous roll for the next iteration
        prev_roll=("${rolled_numbers[@]}")
    done

    echo "Total repeated permutations: $repeat_count"
}

# Set number of trials and dice for testing
test_permutations 6000 5
