# xamionex.PilotsVsBoss

### This is my mod for the PvB server that i host
## How to install on your server
1. Open ns_startup_args_dedi.txt
   - Add to your playlist var overrides:
     - +setplaylistvaroverrides "custom_air_accel_pilot 9000 featured_mode_amped_tacticals 1 fp_embark_enabled 1 oob_timer_enabled 0 no_pilot_collision 1"
2. Place the latest release into R2Northstar\mods\
3. Open R2Northstar\mods\Northstar.CustomServers\mod\cfg\autoexec_ns_server.cfg
   - ns_private_match_last_mode ffa
   - slide_step_velocity_reduction -45
4. Done, you can enjoy your PilotsVsBoss server!