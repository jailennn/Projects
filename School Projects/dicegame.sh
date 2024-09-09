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
    declare -A probabilities
    entropy=0
    total_rolls=$((trials * num_dice))

    echo "$trials trials stats($num_dice rolled per trial):"
    sleep 1
    
    # calculate and display tally stats in order
    for num in $(printf "%s\n" "${!tally[@]}" | sort -n); do
        probabilities[$num]=$(echo "scale=10; ${tally[$num]} / $trials" | bc -l)
        percentage=$(echo "scale=2; ${probabilities[$num]} * 100" | bc -l)
        rounded_percentage=$(printf "%.2f" "$percentage")
        echo "$num - ${tally[$num]}, $rounded_percentage%"
    done

    # odd and even calculation based on rolled numbers
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
    total_counts=$((odds_count + evens_count))
    if (( total_counts > 0 )); then
        odd_percentage=$(echo "scale=2; $odds_count * 100 / $total_counts" | bc -l)
        even_percentage=$(echo "scale=2; $evens_count * 100 / $total_counts" | bc -l)
    else
        odd_percentage=0
        even_percentage=0
    fi

    echo "Odds - $odd_percentage%"
    echo "Evens - $even_percentage%"

    # entropy calculation if 1 die is rolled
    if (( num_dice == 1 )); then
        for prob in "${probabilities[@]}"; do
            if (( $(echo "$prob > 0" | bc -l) )); then
                entropy=$(echo "scale=10; $entropy - $prob * l($prob)/l(2)" | bc -l)
            fi
        done
        round_num=$(printf "%.2f" "$entropy")
        sleep 1
        echo "Entropy value - $round_num bits"
    fi
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
run_trials() {
    declare -A tally
    declare -i double_count=0
    declare -i correlation_count=0
    declare -i sequential_count=0

    # Track previous rolls for lagged correlation
    declare -A previous_rolls

    for ((i=0; i<$trials; i++)); do
        rolled_numbers=($(roll_dice $num_dice))

        if (( num_dice == 2 )); then
            # Sum calculation for two dice
            sum=$(( ${rolled_numbers[0]} + ${rolled_numbers[1]} ))
            ((tally[$sum]++))

            # Check for doubles
            if [[ ${rolled_numbers[0]} -eq ${rolled_numbers[1]} ]]; then
                ((double_count++))
            fi

        elif (( num_dice > 2 )); then
            # Tally sums for multiple dice
            sum=0
            for num in "${rolled_numbers[@]}"; do
                sum=$((sum + num))
            done
            ((tally[$sum]++))

        else
            # Regular tally for 1 die
            for num in "${rolled_numbers[@]}"; do
                ((tally[$num]++))
            done

            # Check for sequential patterns only if 1 die is rolled
            if (( num_dice == 1 )); then
                if (( i >= 2 )); then
                    # Compare with the last two rolls
                    prev_roll_1=(${previous_rolls["$((i-1))"]})
                    prev_roll_2=(${previous_rolls["$((i-2))"]})

                    # Sort current and previous rolls for permutation check
                    sorted_current=($(echo "${rolled_numbers[@]}" | tr ' ' '\n' | sort -n))
                    sorted_prev_1=($(echo "${prev_roll_1[@]}" | tr ' ' '\n' | sort -n))
                    sorted_prev_2=($(echo "${prev_roll_2[@]}" | tr ' ' '\n' | sort -n))

                    # Check for sequential patterns (ascending or descending)
                    if [[ "${rolled_numbers[@]}" == $(seq "${rolled_numbers[0]}" "${rolled_numbers[$((num_dice-1))]}") ]]; then
                        ((sequential_count++))
                    elif [[ "${rolled_numbers[@]}" == $(seq -s ' ' -f "%.0f" "${rolled_numbers[0]}" -1 "${rolled_numbers[$((num_dice-1))]}") ]]; then
                        ((sequential_count++))
                    fi

                    # Check if current roll matches either of the last two
                    if [[ "${sorted_current[*]}" == "${sorted_prev_1[*]}" || "${sorted_current[*]}" == "${sorted_prev_2[*]}" ]]; then
                        ((correlation_count++))  # Tally the correlation (repeat)
                    fi
                elif (( i == 1 )); then
                    # Only compare with the first roll
                    prev_roll=(${previous_rolls["$((i-1))"]})

                    sorted_current=($(echo "${rolled_numbers[@]}" | tr ' ' '\n' | sort -n))
                    sorted_previous=($(echo "${prev_roll[@]}" | tr ' ' '\n' | sort -n))

                    if [[ "${sorted_current[*]}" == "${sorted_previous[*]}" ]]; then
                        ((correlation_count++))  # Tally the correlation (repeat)
                    fi
                fi
                # Store the current roll in previous_rolls for future comparison
                previous_rolls["$i"]="${rolled_numbers[*]}"
            fi
        fi
    done  # <-- This is the closing 'done' for the for loop

    sleep 1
    calculate_randomness

    # Output the number of doubles if 2 dice are rolled
    if (( num_dice == 2 )); then
        double_percentage=$(echo "scale=2; $double_count * 100 / $trials" | bc -l)
        echo "Doubles - $double_count, $double_percentage%"
    fi

    # Output the total number of lagged correlations (repeats)
    correlation_percentage=$(echo "scale=2; $correlation_count * 100 / $trials" | bc -l)
    echo "Repeats - $correlation_count, $correlation_percentage%"

    # Output the total number of sequential patterns detected, only if 1 die is rolled
    if (( num_dice == 1 )); then
        echo "Sequential Rolls - $sequential_count"
    fi
}
# call to start playing the game
start_game
run_trials
