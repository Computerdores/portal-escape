# Portal Escape

The core of this repo is `portal-escape.sh`.

It is a NetworkManager dispatcher script which attempts to provide auto-login for captive portals.
To do this, it temporarily stop all wg-quick units (to prevent IP collisions) and then makes the same requests a user would trigger when interacting normally with the captive portal.

Currently supported captive portals:
- WIFI@DB (should work on trains, not sure about in-station wifi)
- WIFIonICE (untested, but should work)

## Installing
For non-NixOS see [ArchWiki/NetworkManager](https://wiki.archlinux.org/title/NetworkManager).

On NixOS:
TODO

