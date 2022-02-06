# What does it do

- A random player is picked to be a boss, with increasing HP (player scaled)
- Another player from the survivors/pilots team is picked to be Amped (more hp, inf stim)

## How do you win

- The boss wins by timeout or killing all pilots
- The pilots win by killing the boss

## How to install on your server

1. Extract the latest release, open `mods` folder and place xamionex.PilotsVsBoss into R2Northstar\mods\
2. Open R2Northstar\mods\Northstar.CustomServers\mod\cfg\autoexec_ns_server.cfg
   - For Client not needed:
      - ns_private_match_last_mode hidden
   - For Client needed:
      - ns_private_match_last_mode pvb
   - slide_step_velocity_reduction -45
3. Done, you can enjoy your PilotsVsBoss server!
