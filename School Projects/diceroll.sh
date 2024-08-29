#!/bin/bash
# "Client Program"
roll_dice() {
    echo $(( ( RANDOM % 6 ) + 1 ))
}

# function to get user input for # of dice, also checking that the input is an integer 1-5.
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

#call to get number of dice prior to rolling
get_num_dice

# generate the random value(roll the dice) and add each rolled value to resuilts
results=()
for (( i=0; i<$num_dice; i++ )); do
    results+=($(roll_dice))
done

# Print the results(rolled values)
echo "You rolled: ${results[@]}"
