#!/bin/bash
# client Section
# function to get user input for # of dice, also checking that the input is an integer 1-5.
get_num_dice() {
    while true; do
        echo "How many dice to roll? "
        read num_dice # reads in number that user inputs
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
    # calls for user input
    get_num_dice
    # roll the dice and add each rolled value to results
    results=()
    for (( i=0; i<$num_dice; i++ )); do
        results+=($(roll_dice 1))
    done
    echo "Rolled - ${results[@]}"
}
# AI assistant was used to help wrtie the following section of code.
#My prompt: What’s the best way to implement the entropy formula in Bash using logarithm calculation.
#AI Output:"
# Check if input file is provided
#if [ "$#" -ne 1 ]; then
    #echo "Usage: $0 <probabilities_file>"
    #exit 1
#fi
# File containing probabilities (one per line)
#PROB_FILE=$1
# Initialize variables
#entropy=0
# Read probabilities from the file
#while IFS= read -r prob; do
    # Skip empty lines or lines that do not represent valid probabilities
    #if [ -z "$prob" ] || [ "$(echo "$prob > 0" | bc)" -eq 0 ]; then
        #continue
    #fi

    # Calculate log2(prob) using bc
    #log2=$(echo "scale=10; l($prob) / l(2)" | bc -l)

    # Update entropy using bc
    #entropy=$(echo "scale=10; $entropy - ($prob * $log2)" | bc -l)
#done < "$PROB_FILE"
# Output the entropy
#echo "Entropy: $entropy"
# Note: AI provided output has been altered to fully meet my needs.
calculate_entropy() { # calculate entropy function(only called if test trials are run)
    declare -A probabilities # associative array declaration
    entropy=0
    total_rolls=$((trials * 5)) # 5 dice per trial
    
    # probability calculation using basic calculator
    for num in "${!tally[@]}"; do
        probabilities[$num]=$(echo "scale=10; ${tally[$num]} / $total_rolls" | bc -l)
    done

    # entropy calculation
    for prob in "${probabilities[@]}"; do
        if (( $(echo "$prob > 0" | bc -l) )); then
            entropy=$(echo "scale=10; $entropy - $prob * l($prob)/l(2)" | bc -l) 
        fi
    done
    round_num=$(printf "%.2f" "$entropy")
    sleep 1
    echo "Entropy value - $round_num bits"
}
# AI assistant was used to help wrtie the following section of code.
# My prompt: "How can I test multiple trials of rolling 5 dice and tally the results for each possible outcome using a bash function and loop"
#AI Output:"
#num_trials=1000
#roll_dice() {
  #local rolls=()
  #for _ in {1..5}; do
    #rolls+=($((RANDOM % 6 + 1)))
  #done
  #printf -v outcome "%s " "${rolls[@]}"
  #outcome=$(echo $outcome | tr ' ' '\n' | sort -n | tr '\n' ' ' | xargs)
  #echo "$outcome"
#}
#for ((i=1; i<=num_trials; i++)); do
  #outcome=$(roll_dice)
  #((outcome_counts["$outcome"]++))
#done
# Print the results
#echo "Outcome\tCount"
#for outcome in "${!outcome_counts[@]}"; do
  #echo -e "$outcome\t${outcome_counts[$outcome]}"
#done"
# Note: AI provided output has been altered to fully meet my needs.
run_trials() { # function to run trials and tally results(testing part of code).
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
    echo "$trials trials tally: "
    sleep 1
    for num in "${!tally[@]}"; do
        echo "$num - ${tally[$num]}"
    done
    calculate_entropy
}

# driver section
# call to start playing the game
start_game
while true; do
    read -p "Run entropy tests? (Y/N): " choice
    case "$choice" in
        [Yy] )
            num_trials=60 # test 1 set at 60 trials
            run_trials $num_trials

            num_trials=600 # test 2 set at 600 trials
            run_trials $num_trials

            num_trials=6000 # test 3 set at 6000 trials
            run_trials $num_trials
            exit 0
            ;;
        [Nn] )
            exit 0
            ;;
        * )
            echo "Please answer 'Y' for Yes or 'N' for No."
            ;;
    esac
done
