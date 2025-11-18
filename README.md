# Portal Escape

The core of this repo is `portal-escape.sh`.

It is a NetworkManager dispatcher script which attempts to provide auto-login for captive portals.
To do this, it temporarily stop all wg-quick units (to prevent IP collisions) and then makes the same requests a user would trigger when interacting normally with the captive portal.

Currently supported captive portals:
- WIFI@DB (works on trains, not sure about in-station wifi)
- WIFIonICE (untested, but should work)

## Installing
For non-NixOS see [ArchWiki/NetworkManager](https://wiki.archlinux.org/title/NetworkManager).

On NixOS:

1. Add this repo to your flake inputs

```nix
# flake.nix
{
    inputs = {
        # ...
        portal-escape = {
            url = "github:Computerdores/portal-escape";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    }
    # ...
}
```

2. Add the script as a dispatcher and make sure portal detection works (`nmcli -t -f CONNECTIVITY general` while behind a captive portal should return `portal`)

```nix
# configuration.nix
{ ... }:
let
    portal-escape = inputs.portal-escape.packages.${system}.default;
in {
    networking.networkmanager = {
        enable = true;
        # default portal detection is broken, this should fix it
        settings.connectivity = {
            uri = "http://detectportal.firefox.com/canonical.html";
            response = ''<meta http-equiv="refresh" content="0;url=https://support.mozilla.org/kb/captive-portal"/>'';
        };
        # add the script as a dispatcher
        dispatcherScripts = [{
            type = "basic";
            source = "${portal-escape}/bin/portal-escape";
        }];
    }
}
```

## Contributing
Just open a PR.
