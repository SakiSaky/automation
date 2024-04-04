'''
List fire-type Pokémons from https://pokeapi.co via Python
Check if request library is available with 'pip list' command
If missing, then install it with 'pip install requests' command
'''
import requests

# Get list of fire-type Pokémons from API
def get_fire_pokemon():
    '''Returns the fire_pokemon_names list'''
    url = "https://pokeapi.co/api/v2/type/fire"
    response = requests.get(url)

    if response.status_code == 200:
        data = response.json()
        fire_pokemon_names = []
        for pokemon in data['pokemon']:
            fire_pokemon_names.append(pokemon['pokemon']['name'])
        fire_pokemon_names.sort()
        return fire_pokemon_names
    else:
        print("Response error from Pokémon API. Try it later")
        return None

#  Main function
def main():
    '''Print the fire_pokemon_names list'''
    fire_pokemon_names = get_fire_pokemon()
    if fire_pokemon_names:
        # Print fire-pokemons list
        print("Fire-type Pokémons:")
        for name in fire_pokemon_names:
            print(name)
    else:
        print("No fire-type Pokémon found")

if __name__ == "__main__":
    main()
