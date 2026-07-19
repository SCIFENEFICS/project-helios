# Project Helios Status

## Current phase

Version 1 project structure completed and validated.

No installation has been performed yet.

## Target platform

- Debian 13 Minimal
- Xorg
- Openbox
- LightDM
- Automatic login
- Flex Launcher

## Main applications

- Moonlight
- Plex HTPC
- FreeTube
- Brave Browser
- Spotify
- MPV
- PCManFM

## System features prepared

- Automatic login to the `helios` user
- Dedicated Project Helios X session
- Automatic Openbox startup
- Automatic Flex Launcher startup
- Fullscreen and maximized application rules
- Screen blanking and DPMS disabled
- Hidden maintenance menu
- Ctrl + Alt + M maintenance shortcut
- Network configuration access
- Audio configuration access
- VA-API verification
- Project logging
- Project validation
- Project snapshots

## Installation scripts prepared

- install.sh
- install-base.sh
- install-apps.sh
- install-external.sh
- configure-system.sh
- configure-flex.sh
- verify-vaapi.sh
- app-selector.sh
- validate-project.sh

## Package sources

### Debian packages

Used for the core graphical environment, audio, networking, file management,
SMB support, MPV, Flatpak, maintenance tools and diagnostics.

### Flatpak applications

- Moonlight
- Plex HTPC
- FreeTube
- Spotify

### External applications

- Brave Browser from the official Brave Debian repository
- Flex Launcher from its official GitHub release

## Deferred until later

- Custom Helios branding
- Custom launcher icons
- Custom background image
- Polished theme
- SMB server details
- Remote-control mapping
- Home-button behaviour
- ISO image creation
- Automated Debian installation
- Hardware-specific testing
- Application-specific login and configuration

## Current validation result

All required files passed the project validation script on 18 July 2026.

## Latest snapshot

    output/snapshots/project-helios-2026-07-18_20-17-34.tar.gz
