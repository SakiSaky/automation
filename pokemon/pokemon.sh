#!/bin/bash
#
# List fire-type Pokémons from https://pokeapi.co 
# 

#######################################
# Function to get a list of fire-type Pokémon names
# Return fire_pokemon_names  alphabetically sorted or exits with error
#######################################
get_fire_pokemon() {
  local url="https://pokeapi.co/api/v2/type/fire"
  local response=$(curl -s "$url")

  if [ $? -eq 0 ]; then
    local fire_pokemon_names=$(echo "${response}" | jq -r '.pokemon[].pokemon.name' | sort)
    echo "${fire_pokemon_names}"
  else
    echo "Response error from Pokémon API. Try it later"
    exit 1
  fi
}

#######################################
# Function ask and install JQ if necessary
#######################################
ask_and_install_jq() {
  while [ -z $prompt ]
  do 
    read -p "JQ is required to run this script. Would like to install JQ JSON processor (y/n)?" choice
    case "$choice" in
      y|Y ) sudo apt-get install jq ; sudo yum install jq ; sudo dnf install jq ; break ;;
      n|N ) break ;;
    esac
  done
  # Check success of installation
  if [ -z "$(which jq)" ]; then
    echo "JQ installation not successed. Do it manually please!"
    exit 1
  fi
}

#######################################
# Main function
#######################################
main() {
  # Checking is JQ installed and start installation function if not
  if [ -z "$(which jq)" ]; then
    echo "JQ is not installed"
    ask_and_install_jq
  fi
  # Get pokemon names with help of JQ via get_fire_pokemon function
  local fire_pokemon_names=$(get_fire_pokemon)
  if [ -n "$fire_pokemon_names" ]; then
    echo "Fire-type Pokémons:"
    echo "${fire_pokemon_names}"
  else
    echo "No fire-type Pokémon found"
  fi
}

main
