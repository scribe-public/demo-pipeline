#!/bin/bash

# Input arguments
input_finding_file=$1
output_finding_file=$2
info=$3

# Check if input file exists
if [ ! -f "$input_finding_file" ]; then
  echo "Input finding file does not exist: $input_finding_file"
  exit 1
fi

# Read the input JSON file
orig=$(cat "$input_finding_file")

# Add the "fix" key with the provided info
fixed=$(echo "$orig" | jq --arg info "$info" '. + {fix: $info}')

# Write the updated JSON to the output file
echo "$fixed" > "$output_finding_file"

# Confirm completion
echo "Updated finding written to: $output_finding_file"