#!/bin/bash
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

calculate_randomness() {
    declare -A probabilities
    entropy=0
    total_rolls=$((trials * num_dice))

    echo "$trials trials stats($num_dice rolled per trial):"
    sleep 1
    
    for num in $(printf "%s\n" "${!tally[@]}" | sort -n); do
        probabilities[$num]=$(echo "scale=10; ${tally[$num]} / $trials" | bc -l)
        percentage=$(echo "scale=2; ${probabilities[$num]} * 100" | bc -l)
        rounded_percentage=$(printf "%.2f" "$percentage")
        echo "$num - ${tally[$num]}, $rounded_percentage%"
    done

    odds_count=0
    evens_count=0
    for num in "${!tally[@]}"; do
        if (( num % 2 == 1 )); then
            odds_count=$((odds_count + tally[$num]))
        else
            evens_count=$((evens_count + tally[$num]))
        fi
    done

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

run_trials() {
    declare -A tally
    declare -i double_count=0
    declare -i correlation_count=0
    declare -i sequential_count=0

    # Track previous rolls for lagged correlation
    declare -A previous_rolls

    for ((i=0; i<$trials; i++)); do
        rolled_numbers=($(roll_dice $num_dice))
        sorted_current=$(printf "%s\n" "${rolled_numbers[@]}" | sort -n | tr '\n' ' ' | sed 's/ $//')

        if (( num_dice == 2 )); then
            sum=$(( ${rolled_numbers[0]} + ${rolled_numbers[1]} ))
            ((tally[$sum]++))

            if [[ ${rolled_numbers[0]} -eq ${rolled_numbers[1]} ]]; then
                ((double_count++))
            fi

            if (( i >= 1 )); then
                prev_sorted="${previous_rolls["$((i-1))"]}"

                # Compare current sorted roll with the previous one for repeats
                if [[ "$sorted_current" == "$prev_sorted" ]]; then
                    ((correlation_count++))
                fi
            fi

            # Store the current roll in previous_rolls for future comparison
            previous_rolls["$i"]="$sorted_current"

        elif (( num_dice > 2 )); then
            sum=0
            for num in "${rolled_numbers[@]}"; do
                sum=$((sum + num))
            done
            ((tally[$sum]++))

            if (( i >= 1 )); then
                prev_sorted="${previous_rolls["$((i-1))"]}"

                if [[ "$sorted_current" == "$prev_sorted" ]]; then
                    ((correlation_count++))
                fi
            fi

            previous_rolls["$i"]="$sorted_current"

        else
            for num in "${rolled_numbers[@]}"; do
                ((tally[$num]++))
            done

            if (( i >= 2 )); then
                prev_roll_1=${previous_rolls["$((i-1))"]}
                prev_roll_2=${previous_rolls["$((i-2))"]}

                if [[ "$rolled_numbers" -eq "$((prev_roll_1 + 1))" && "$rolled_numbers" -eq "$((prev_roll_2 + 2))" ]]; then
                    ((sequential_count++))
                fi

                if [[ "$rolled_numbers" -eq "$prev_roll_1" || "$rolled_numbers" -eq "$prev_roll_2" ]]; then
                    ((correlation_count++))
                fi
            elif (( i == 1 )); then
                prev_roll=${previous_rolls["$((i-1))"]}

                if [[ "$rolled_numbers" -eq "$prev_roll" ]]; then
                    ((correlation_count++))
                fi
            fi
            previous_rolls["$i"]="$rolled_numbers"
        fi
    done

    sleep 1
    calculate_randomness

    if (( num_dice == 2 )); then
        double_percentage=$(echo "scale=2; $double_count * 100 / $trials" | bc -l)
        echo "Doubles - $double_count, $double_percentage%"
    fi

    correlation_percentage=$(echo "scale=2; $correlation_count * 100 / $trials" | bc -l)
    echo "Repeats - $correlation_count, $correlation_percentage%"

    if (( num_dice == 1 )); then
        echo "Sequential Rolls - $sequential_count"
    fi
}

start_game
run_trials
