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
- Flatpak application support

### In Progress

- Boot time optimisation
- Controller navigation and compatibility testing
- Installer language, menu and hardware testing
- Timezone and network-time validation
- First-boot setup presentation and progress feedback
- Complete and verify the controller-friendly update system
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
- Brave Origin
- Files
- Helios Update

> [!NOTE]
> **An internet connection is required during first boot.**
>
> Helios installs Brave Origin and its Flatpak media applications after the installed system starts for the first time. If setup cannot complete, Helios retries it on a later startup.

## First Boot

When Helios starts for the first time, it automatically prepares the included online applications.

This currently includes:

- Installing Brave Origin
- Installing Moonlight
- Installing Plex HTPC
- Installing VacuumTube
- Installing Spotify
- Updating installed Flatpak applications

A working internet connection is required. Setup completes once and is retried on a later startup if it cannot finish.

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
- Brave Origin
- VacuumTube

## License

Project Helios is open-source software. Individual applications and upstream projects remain subject to their respective licenses.
