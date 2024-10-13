#!/bin/bash

# Directory containing images
input_dir=~/testimgs
output_dir=~/encfiles

# Ensure output directory exists
mkdir -p "$output_dir"

# RSA public key
public_key=public_key.pem

# Start time in nanoseconds
start_time=$(date +%s%N)

# Loop through all PNG images in the input directory
for img in "$input_dir"/*.png; do
    # Generate a random AES key for each file
    aes_key=$(openssl rand -base64 32)

    # Encrypt the image with AES using the generated key
    encrypted_image="$output_dir/$(basename "$img").aes"
    echo -n "$aes_key" | openssl enc -aes-256-cbc -salt -in "$img" -out "$encrypted_image" -pass stdin 2>/dev/null

    # Encrypt the AES key using RSA and save it to a file
    encrypted_key="$output_dir/$(basename "$img").key.enc"
    echo -n "$aes_key" | openssl pkeyutl -encrypt -inkey "$public_key" -pubin -out "$encrypted_key" 2>/dev/null
done

# End time in nanoseconds
end_time=$(date +%s%N)

# Calculate execution time in milliseconds
execution_time=$(( (end_time - start_time) / 1000000 ))

echo "Execution time: $execution_time ms"
