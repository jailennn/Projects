#!/bin/bash
# client Section
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
# function for generating a random integer ranging from 1-6 (rolling a dice)
roll_dice() {
    num_dice=$1
    results=()
    for ((i=0; i<num_dice; i++)); do
        results+=($(( ( RANDOM % 6 ) + 1 )))
    done
    echo "${results[@]}"
}
start_game() { # function to begin playing game
    # get number of dice to roll from user input
    get_num_dice
    # roll the dice and add each rolled value to results
    results=()
    for (( i=0; i<$num_dice; i++ )); do
        results+=($(roll_dice 1))
    done
    echo "You rolled: ${results[@]}"
}
# function to run trials and tally results(testing part of code).
#AI assistant was used to help wrtie the following function
#
run_trials() {
    trials=$1
    declare -A tally # associative array declaration

    for ((i=0; i<$trials; i++)); do
        # roll 5 dice(max at once) and store them
        rolled_numbers=$(roll_dice 5)

        # tally results in the associative array
        for num in $rolled_numbers; do
            ((tally[$num]++))
        done
    done

    # display tally results
    echo "Tally of rolled numbers after $trials trials:"
    sleep 1
    for num in "${!tally[@]}"; do
        echo "$num: ${tally[$num]}"
    done
    calculate_entropy
}
calculate_entropy() { # calculate entropy(only if test trials are run)
    declare -A probabilities
    entropy=0

    # probability calculation
    for num in "${!tally[@]}"; do
        probabilities[$num]=$(echo "scale=10; ${tally[$num]} / $trials" | bc -l)
    done

    # entropy calculation
    for prob in "${probabilities[@]}"; do
        if (( $(echo "$prob > 0" | bc -l) )); then
            entropy=$(echo "scale=10; $entropy - $prob * l($prob)/l(2)" | bc -l)
        fi
    done
    round_num=$(printf "%.2f" "$entropy")
    sleep 1
    echo "Entropy value: $round_num"
}
# driver section
while true; do
    # call to start playing game
    start_game

    # for replay(practicality)
    while true; do
        read -p "Do you want to play again? (Y/N): " play_again
        case "$play_again" in
            [Yy] )
                break
                ;;
            [Nn] )
                # prompt for randomness test decision if not playing again
                while true; do
                    read -p "Do you want to run some entropy randomness tests? (Y/N): " choice
                    case "$choice" in
                        [Yy] )
                            num_trials=60 # test 1 set at 60 trials
                            echo "Starting Test 1 with $num_trials trials..."
                            run_trials $num_trials
                            num_trials=600 #test 2 set at 600 trails
                            echo "Starting Test 2 with $num_trials trials..."
                            run_trials $num_trials
                            num_trials=6000 # test 3 set at 6000 trials
                            echo "Starting Test 3 with $num_trials trials..."
                            run_trials $num_trials
                            exit 0
                            ;;
                        [Nn] )
                            echo "Thanks for playing!"
                            exit # exiting script
                            ;;
                        * )
                            echo "Please answer 'Y' for Yes or 'N' for No."
                            ;;
                    esac
                done
                ;;
            * )
                echo "Please answer 'Y' for Yes or 'N' for No."
                ;;
        esac
    done
done
