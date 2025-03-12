# Fedora
 Auto setup project for Fedora

-----------------------------------------------------------------------------
This snippet disables WirePlumber's automatic switching to the HSP/HFP profile.

By default, when a Bluetooth headset is connected, WirePlumber may auto-switch the headset to the HSP/HFP (hands-free) profile when it detects an input stream. This automatic switch often forces the headset into a lower-quality mode, which is undesirable for users who primarily want high-fidelity audio (A2DP).

By appending this configuration:
   wireplumber.settings = {
     bluetooth.autoswitch-to-headset-profile = false
   }

...we instruct WirePlumber to keep the current profile (usually A2DP) and not switch automatically, preserving audio quality for playback.

Note: Disabling auto-switching means that if you need to use the microphone, you will have to manually switch the profile (for example, using `pactl set-card-profile`) or changing it using pavucontrol/GNOME system menu.

## To apply this change, run:
```sh
cat << EOF | sudo tee -a /usr/share/wireplumber/wireplumber.conf
-- Disable automatic switching to HSP/HFP (headset mode)
wireplumber.settings = {
  bluetooth.autoswitch-to-headset-profile = false
}
EOF
```

-----------------------------------------------------------------------------
After running the command, restart WirePlumber or reboot your system to ensure the new setting is loaded.
