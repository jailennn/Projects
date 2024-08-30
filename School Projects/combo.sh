#!/bin/bash
# Client Section

# Function for generating a random integer ranging from 1-6 (rolling a dice)
roll_dice() {
    local num_dice=$1
    results=()
    for ((i=0; i<num_dice; i++)); do
        results+=($(( ( RANDOM % 6 ) + 1 )))
    done
    echo "${results[@]}"
}

# Function to get user input for # of dice, also checking that the input is an integer 1-5.
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

# Function to run trials and tally results
run_trials() {
    local trials=$1
    declare -A tally # Associative array declaration

    for ((i=0; i<$trials; i++)); do
        # Roll 5 dice and store them in a variable
        rolled_numbers=$(roll_dice 5)

        # Tally the results in the associative array
        for num in $rolled_numbers; do
            ((tally[$num]++))
        done
    done

    # Display the tally results
    echo "Tally of rolled numbers after $trials trials:"
    for num in "${!tally[@]}"; do
        echo "$num: ${tally[$num]}"
    done
}

#Driver Section
#call to get number of dice to roll prior to rolling
get_num_dice

# add each rolled value to results
results=()
for (( i=0; i<$num_dice; i++ )); do
    results+=($(roll_dice))
done

# print value of each result
echo "You rolled: ${results[@]}"

# prompt user for randomness test decision. Ensures dice game can still be played normally, only testing randomness when user wants to.
while true; do
    read -p "Do you want to run randomness tests? (Y/N): " choice
    case "$choice" in # pattern match case to only accept y,n,Y,N.
        [Yy] )
            num_trials=60
            echo "Starting Test 1..."
            run_trials $num_trials
            break
            ;;
        [Nn] )
            echo "Thanks for playing!"
            exit 0
            ;;
        * )
            echo "Please answer Y or N."
            ;;
    esac
done
