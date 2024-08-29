#!/bin/bash
roll_dice() {
    echo $(( ( RANDOM % 6 ) + 1 ))
}

# Function to get the number of dice to roll with validations
get_num_dice() {
    while true; do
        echo "How many dice do you want to roll? (1-5)"
        read num_dice
        if [[ "$num_dice" =~ ^[1-5]$ ]]; then
            break
        else
            echo "Invalid input. Please enter an integer between 1 and 5."
        fi
    done
}

# Get the number of dice to roll
get_num_dice

# Roll the dice and store the results in an array
results=()
for (( i=0; i<$num_dice; i++ )); do
    results+=($(roll_dice))
done

# Print the results
echo "You rolled: ${results[@]}"
