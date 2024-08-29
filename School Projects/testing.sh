#!/bin/bash
# Function to roll dice
roll_dice() {
    local num_dice=$1
    results=()
    for ((i=0; i<num_dice; i++)); do
        results+=($((RANDOM % 6 + 1)))
    done
    echo "${results[@]}"
}

# Function to get a valid integer input from the user
get_valid_integer() {
    local prompt=$1
    local user_input
    while true; do
        # Prompt the user for input
        read -p "$prompt" user_input

        # Check if the input is a single digit between 1 and 5
        if [[ "$user_input" =~ ^[1-5]$ ]]; then
            # Valid input; return the value
            echo "$user_input"
            return
        else
            # Invalid input; show an error message and prompt again
            echo "Invalid input. Please enter an integer between 1 and 5."
        fi
    done
}

# Main function
main() {
    # Get the number of dice to roll
    num_dice=$(get_valid_integer "Enter the number of dice to roll (1-5): ")

    # Roll the dice and display the results
    echo "Rolling $num_dice dice: "
    results=$(roll_dice $num_dice)
    echo $results
}

# Run the main function
main
