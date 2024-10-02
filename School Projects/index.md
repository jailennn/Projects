# Dice Rolling Randomness Testing Script
## Project Overview

This script was developed for a **Software Development and Testing** class to simulate rolling dice, analyze the randomness of the results, and calculate statistical metrics such as probabilities, entropy, and repeat patterns across multiple trials. 
The script allows users to input the number of dice and trials, and it performs several statistical tests to evaluate the randomness and fairness of the dice rolls.

---

## Key Features

### 1. **User Input Handling**
- **Number of Dice**: The script prompts the user to input the number of dice they wish to roll (between 1-5).
- **Number of Trials**: After choosing the number of dice, the user is asked to input how many trials to run, allowing them to test how randomness behaves over repeated rolls.

### 2. **Dice Rolling Simulation**
- The core of the script simulates rolling a number of dice (between 1 and 5). 
- Each die generates a random number between 1-6 using the Bash `RANDOM` function.
- The results of each roll are stored for later analysis.

### 3. **Randomness Calculation**
After rolling the dice over the specified number of trials, the script performs several calculations:
- **Probabilities**: The script calculates the percentage occurrence of each number (or sum of numbers) and displays it to the user.
- **Odd/Even Distribution**: For each trial, the script tallies how often odd and even numbers appear and calculates their respective percentages.
- **Entropy Calculation**: For 1-die scenarios, entropy is calculated to assess the unpredictability of the rolls. Higher entropy values indicate more randomness.
  
### 4. **Statistical Testing**
The script performs several tests on the rolled results:
- **Doubles (for 2 dice)**: If 2 dice are rolled, the script counts how often both dice show the same number and displays the percentage of doubles.
- **Repeats**: The script tracks how often consecutive rolls show the same outcome (i.e., correlation between consecutive trials).
- **Sequential Rolls (for 1 die)**: The script checks for forward or backward sequences in the rolls (e.g., 1 followed by 2, then 3) and counts how often these sequences occur.

### 5. **Output Display**
After completing all the trials, the script presents a summary of the results, including:
- Probabilities of each rolled number (or sum for multiple dice)
- Odd/Even percentages
- The entropy value (for single dice)
- Percentage of doubles (for two dice)
- Repeat (correlation) percentage
- Sequential roll counts (for one die)

---

## Purpose & Usage
1. Understand randomness and probability through software and statistical analysis.
3. Implement methods to test and evaluate the fairness of random processes (e.g., dice rolls).

To use the script:
- Run the shell script in a Bash environment.
- Follow the prompts to enter the number of dice and trials.
- Observe the output, which includes statistical results and randomness analysis.

---

## Further Development
In future iterations, additional randomness checks could be implemented, such as:
- Testing for patterns beyond doubles and repeats.
- Adding functionality for more complex randomness calculations when rolling multiple dice.
- Graphical representation of randomness data.

---

**Developed by Jailen for Software Development and Testing class**.

