# automation

### azure/main.sh
 - Create user, group and put that user to group if not exist in Enrta ID
 - Create VM, add it to Entra ID, and enable RDS to user if not exist

**Important notes:**
- After user creation necessary to login with that user to the https://portal.azure.com to make
  necessary steps. Without this login with RDS will fail with credential error. 
- Connection method to the remote Microsoft Entra joned device written in article:
  https://learn.microsoft.com/en-us/windows/client-management/client-tools/connect-to-remote-aadj-pc
- Please change vatiables.sh values of variables according the requirements, mainly the **DOMAIN_NAME**
  and **TENANT_ID** values. 

### docker/Docker
  - Create container with This Docker file with command
   `build -t ubuntu-node-time . && docker run --rm ubuntu-node-time`
  - This command prints out the current time as a Unix epoch and then delete the container

### pokemon/pokemon.sh
### pokemon/pokemon.py
  - Both consumes PokéAPI from https://pokeapi.co/, and lists all fire-type Pokemons by name


