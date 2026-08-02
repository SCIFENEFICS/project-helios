# Project Helios

### A controller-first media operating system for TVs

Project Helios is an open-source, Debian-based operating system designed specifically for televisions. It replaces slow, cluttered and advertisement-filled smart TV software with a fast, private and controller-friendly experience that boots directly into your applications.

---

<img width="1296" height="816" alt="image" src="https://github.com/user-attachments/assets/4208f4e2-2eaa-491e-80a2-c65923d1d927" />


---

> [!WARNING]
> **Project Helios is currently under active development and is not yet ready for general installation.**
>
> Installation images are still being developed and tested. This repository is intended for development and evaluation only.

## Current Status

Project Helios is progressing toward its first public release.

### Completed

- Debian 13 operating system
- Bootable installation ISO
- Simplified automatic Helios installer
- Automatic login into the Helios interface
- Lightweight Openbox desktop session
- Custom Flex Launcher integration
- Two-row launcher interface
- Controller support and custom mappings
- Native launcher background support
- Custom Project Helios boot screen
- Hidden GRUB boot menu
- One-click update system
- Flatpak application support

### In Progress

- Boot time optimisation
- Controller compatibility testing
- Installer menu and hardware testing
- Settings interface
- Hardware testing on the MSI Cubi N 8GL

## Features

- Controller-first navigation
- Designed specifically for TVs
- Fast startup
- Lightweight design
- Privacy focused
- No advertisements
- No mandatory accounts
- Flatpak application support
- Integrated update framework
- Replaceable backgrounds and icons

## Included Applications

- Plex HTPC
- Moonlight
- YouTube (VacuumTube)
- Spotify
- MPV
- Brave Browser
- Files
- Helios Update

> [!NOTE]
> **Spotify requires an internet connection during first boot.**
>
> Spotify is installed automatically after Helios starts for the first time. If Helios is not connected to the internet, Spotify will be installed automatically the next time it boots with an internet connection.

## First Boot

When Helios starts for the first time it automatically performs a small amount of setup in the background.

This currently includes:

- Installing Spotify
- Updating installed Flatpak applications

This process starts approximately 15 seconds after boot and only runs once.

A working internet connection is required for this process.

## System Architecture

Project Helios uses a lightweight graphical stack.

```text
Debian Linux
    ↓
LightDM
    ↓
Openbox
    ↓
Flex Launcher
    ↓
Media Applications
```

Openbox provides a lightweight desktop session while Flex Launcher acts as the television interface.

## Flex Launcher

Project Helios uses a customised version of Flex Launcher maintained here:

https://github.com/SCIFENEFICS/flex-launcher/tree/helios

Originally created by ComplexLogic:

https://github.com/complexlogic/flex-launcher

Helios extends Flex Launcher with:

- Two-row layout
- Controller improvements
- Native background rendering
- Helios branding
- Launcher customisation
- Integrated system actions

## Development Workflow

Development takes place inside the dedicated **Helios-Dev VM**.

```text
Helios-Dev VM
      ↓
Build ISO
      ↓
Virtual Machine testing
      ↓
NUC testing
      ↓
GitHub
```

## Credits

Project Helios is built using open-source software, including:

- Debian
- Flex Launcher
- Openbox
- LightDM
- Plymouth
- Flatpak
- SDL2
- MPV
- Moonlight
- Brave
- VacuumTube

## License

Project Helios is open-source software. Individual applications and upstream projects remain subject to their respective licenses.
