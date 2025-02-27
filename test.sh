#!/bin/bash

# Check if film argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <film_name>"
  exit 1
fi

FILM_NAME="$1"
API_URL="https://swapi.dev/api"

# Get the film ID using the provided film name
FILM_ID=$(curl -s "${API_URL}/films/" | jq -r ".results[] | select(.title | test(\"$FILM_NAME\"; \"i\")) | .url" | sed 's/[^0-9]*\([0-9]*\)[^0-9]*$/\1/')

# If the film is not found, exit with error
if [ -z "$FILM_ID" ]; then
  echo "Film '$FILM_NAME' not found."
  exit 1
fi

# Get the list of starships in the film
STARSHIPS=$(curl -s "${API_URL}/films/$FILM_ID/" | jq -r '.starships')

# Initialize empty JSON array to hold starships data
STARSHIP_DATA="[]"

# Loop through each starship URL to get starship details and pilot information
for STARSHIP_URL in $(echo $STARSHIPS | jq -r '.[]'); do
  # Fetch starship details
  STARSHIP=$(curl -s "$STARSHIP_URL")
  
  # Get the name of the starship
  STARSHIP_NAME=$(echo $STARSHIP | jq -r '.name')

  # Get the list of pilots for this starship
  PILOTS=$(echo $STARSHIP | jq -r '.pilots')

  # Initialize empty array for pilot names
  PILOT_NAMES="[]"

  # Loop through each pilot URL to get pilot details
  for PILOT_URL in $(echo $PILOTS | jq -r '.[]'); do
    PILOT=$(curl -s "$PILOT_URL")
    PILOT_NAME=$(echo $PILOT | jq -r '.name')

    # Add pilot name to the array
    PILOT_NAMES=$(echo $PILOT_NAMES | jq --arg name "$PILOT_NAME" '. + [$name]')
  done

  # Add starship and its pilots to the starship data array
  STARSHIP_DATA=$(echo $STARSHIP_DATA | jq --arg name "$STARSHIP_NAME" --argjson pilots "$PILOT_NAMES" '. + [{"name": $name, "pilots": $pilots}]')
done

# Output the final starship data in JSON format
echo $STARSHIP_DATA | jq .

