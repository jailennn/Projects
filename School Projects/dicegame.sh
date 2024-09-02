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
get_num_trials() { # function to get user input for number of trials.
    while true; do
        echo "How many trials to run? "
        read trials # reads in the number that user inputs
        if [[ "$trials" =~ ^[0-9]+$ ]]; then
            break
        else
            echo "Invalid input. Please enter a positive integer."
        fi
    done
}
# function for generating a random integer ranging from 1-6 (rolling a die)
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
    rolled_numbers=$(roll_dice $num_dice)
    
    echo " Rolled - ${rolled_numbers}"
    get_num_trials #prompt for trials after game is played
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
calculate_randomness() {
    declare -A probabilities # associative array declaration
    entropy=0
    total_rolls=$((trials * num_dice)) #total rolls based on the number of trials and dice

    echo "$trials trials stats($num_dice rolled per trial):"
    sleep 1
    for num in $(printf "%s\n" "${!tally[@]}" | sort -n); do # calculate and display tally stats in order
        probabilities[$num]=$(echo "scale=10; ${tally[$num]} / $total_rolls" | bc -l)
        percentage=$(echo "scale=2; ${probabilities[$num]} * 100" | bc -l)
        rounded_percentage=$(printf "%.2f" "$percentage")
        echo "$num - ${tally[$num]}, $rounded_percentage%"
    done

    # odd and even calculation
    odds_count=0
    evens_count=0
    for num in "${!tally[@]}"; do
        if (( num % 2 == 1 )); then
            odds_count=$((odds_count + tally[$num]))
        else
            evens_count=$((evens_count + tally[$num]))
        fi
    done

    # display odds and evens percentages
    odd_percentage=$(echo "scale=2; $odds_count * 100 / $total_rolls" | bc -l)
    even_percentage=$(echo "scale=2; $evens_count * 100 / $total_rolls" | bc -l)
    echo "Odds - $odd_percentage%"
    echo "Evens - $even_percentage%"

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
run_trials() { # function to run trials and tally results (testing part of code)
    declare -A tally # associative array declaration
    for ((i=0; i<$trials; i++)); do
        # roll the number of dice the user selected earlier and store them
        rolled_numbers=$(roll_dice $num_dice)

        # tally results in the associative array
        for num in $rolled_numbers; do
            ((tally[$num]++))
        done
    done
    sleep 1
    # call the randomness calculation function for testing statistics
    calculate_randomness
}
# call to start playing the game
start_game
run_trials
