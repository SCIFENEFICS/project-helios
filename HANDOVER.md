# PROJECT HELIOS — AI HANDOVER

> **MANDATORY:** Every AI working on Project Helios must read this entire file before giving technical instructions.
>
> This is the permanent technical memory and single source of truth for the project. It records architecture, working rules, confirmed results, failed approaches, current problems, and the exact next task.
>
> Update this document whenever useful information changes. Important log entries must include the date and time.

## Document status

- Document version: 1.0
- Created: 2026-08-02 15:30 AEST
- Last updated: 2026-08-02 15:30 AEST
- Current Helios version: 0.5.0
- Debian base: Debian GNU/Linux 13.6 "Trixie"
- Canonical repository: `~/Projects/project-helios`
- Current phase: Make the ISO install, boot, and run all core applications reliably.
- Immediate task: Finish this handover, review and commit the latest installer fixes, rebuild the ISO, inspect its generated files, and test `Install Helios`.

---

# 1. Non-negotiable working rules

## 1.1 How Travis wants technical guidance

- Always state exactly where each command must be run:
  - Helios-Dev VM terminal
  - Pop!_OS host terminal
  - ISO test VM
  - Physical NUC terminal
- Give one command at a time.
- Wait for Travis to paste the result before continuing.
- Always end each technical response with the exact next command or action.
- If Travis says to continue without pasting output, assume the command produced no output unless context proves otherwise.
- Avoid Nano.
- Prefer non-interactive changes using `sed`, `printf`, Python, complete file replacement, or a GUI editor.
- Never invent or assume:
  - paths
  - filenames
  - repository locations
  - usernames
  - IP addresses
  - disk names
  - VM names
  - build commands
- Inspect first, then change.
- Do not repeat a previous fix unless new evidence justifies trying it again.
- Do not claim something is fixed until it has been tested in the installed ISO or on the intended hardware.
- Keep instructions direct and practical. Avoid lengthy speculative explanations when a concrete check is available.
- Do not create duplicate or temporary project repositories for testing.

## 1.2 Canonical repository

All active development and ISO builds happen only here:

`~/Projects/project-helios`

This repository is inside the Helios-Dev VM.

The Pop!_OS host copy is backup-only. Never actively develop, compare, build from, or copy old fixes out of:

`/home/pyrus/vault/projects/Project Helios/`

If another Project Helios folder is discovered, first verify that all required changes exist in the canonical repository, then remove the duplicate to prevent confusion.

## 1.3 Machine roles

### Pop!_OS host

- User: `pyrus`
- Runs KVM/QEMU/libvirt and virt-manager.
- Stores VM disk images, release backups, and the backup-only project copy.
- Historical host IP used during this work: `192.168.10.216`
- Reconfirm the IP before SSH or SCP because it may change.

### Helios-Dev VM

- User: `helios`
- Active development and ISO build environment.
- Canonical repository: `~/Projects/project-helios`
- libvirt VM name: `Helios-Dev`
- Historical VM IP used during this work: `192.168.122.139`
- Reconfirm the IP before SSH because it may change.

### ISO test VM

- Separate from Helios-Dev.
- Used to boot and install newly generated Helios ISOs.
- Do not confuse its installed system with the development VM.

### Physical NUC

- Final target device.
- VM success is not final validation.
- Final milestone testing must be performed on the real NUC.

## 1.4 Git requirements

Main project repository:

`git@github.com:SCIFENEFICS/project-helios.git`

Flex Launcher fork:

`https://github.com/SCIFENEFICS/flex-launcher.git`

Flex Launcher branch:

`helios`

When Flex Launcher source changes:

1. Commit and push the Flex Launcher fork.
2. Update the Flex Launcher submodule reference in the main repository.
3. Commit and push the main repository.
4. Verify both repositories are clean.
5. Verify the main repository references the intended Flex Launcher commit.

Before declaring a milestone complete:

- Main repository must be clean and pushed.
- Flex Launcher repository must be clean and pushed.
- The main project must reference the intended Flex Launcher commit.

After Travis confirms a tested ISO works:

1. Ensure both GitHub repositories are current.
2. Update the Pop!_OS backup from GitHub.
3. Back up the confirmed working project and ISO to Google Drive.

---

# 2. Project Overview

(TODO - complete in next update.)

# 3. Project Architecture

(TODO - complete in next update.)

# 4. Directory Structure

## Main Repository

Canonical development repository:

`~/Projects/project-helios`

Active development occurs only inside the Helios-Dev VM.

---

## Important Main Repository Locations

### `scripts/`

Contains Helios build, installation and maintenance scripts.

Important files:

`build-runtime.sh`
- Creates the runtime filesystem copied into the ISO.
- Deliberately excludes `.git/` and `.github/`.
- The installed `/opt/helios` system is runtime-only.

`configure-system.sh`
- Configures the installed Helios operating system.
- Installs services, scripts, users and system configuration.

`configure-flex.sh`
- Installs and configures Flex Launcher.

`update-helios.sh`
- User-facing Update Helios launcher command.

`helios-update-service.sh`
- Privileged update service backend.

`first-boot-flatpaks.sh`
- First boot Flatpak setup.

---

## `live-build/`

Debian ISO build configuration.

Important locations:

`live-build/config/bootloaders/`
- Syslinux and GRUB installer menus.

`live-build/config/preseed/`
- Debian installer automation settings.

`live-build/config/hooks/`
- Build-time system modifications.

---

## `desktop-files/`

Contains application launcher `.desktop` files.

Important files:

- `brave.desktop`
- `spotify.desktop`
- `update-helios.desktop`
- `moonlight.desktop`
- `plex.desktop`

When an application fails to launch:
Check the desktop file first.

---

## `systemd/`

Helios system services and timers.

Important files:

- `helios-first-boot-flatpaks.service`
- `helios-first-boot-flatpaks.timer`
- `helios-update.service`

---

## `sudoers/`

Restricted privilege rules.

Important:

Only allow required appliance actions.

Do not give Helios unrestricted sudo access.

---

# Flex Launcher Submodule

Location:

`flex-launcher/flex-launcher`

Project Helios maintains a customised Flex Launcher fork.

Important source locations:

## `src/launcher.c`

Main launcher rendering and interface loop.

## `src/launcher.h`

Global structures including:

- Config
- State
- Menu
- Entry

## `src/platform/unix.c`

Linux application launching.

Important:

Desktop applications are launched using the desktop file `Exec=` command.

Do not replace with alternative launch methods without testing all applications.

## `src/util.c`

Configuration parsing.

## `build/`

Generated build files.

Important:

`build/launcher_config.h`

Generated configuration definitions.

---

# Installed Helios Runtime

Location:

`/opt/helios`

Important:

This is NOT the development repository.

It does not contain Git history because `.git/` is intentionally excluded during runtime creation.

Future update systems must use a release/runtime update mechanism.

---

# Common Investigation Locations

## Application launch problems

Check:

1. `desktop-files/*.desktop`
2. `scripts/`
3. `flex-launcher/flex-launcher/src/platform/unix.c`

## ISO missing files

Check:

1. `scripts/build-runtime.sh`
2. live-build configuration

## Installer problems

Check:

1. `live-build/config/bootloaders/`
2. `live-build/config/preseed/`


# 5. Build Process

## Build Environment

All ISO builds happen inside:

`Helios-Dev VM`

Repository:

`~/Projects/project-helios`

Do not build from the Pop!_OS backup copy.

---

## Main Build Command

The normal ISO build command is:

`./build.sh`

The build process:

1. Prepares the live-build directory.
2. Creates the Helios runtime.
3. Applies Debian live-build configuration.
4. Builds the installer ISO.
5. Runs validation checks.
6. Copies releases/backups when configured.

---

## Runtime Creation

Runtime files are assembled by:

`scripts/build-runtime.sh`

This creates the installed Helios runtime.

Important:

- `.git/` is intentionally excluded.
- `.github/` is intentionally excluded.
- `/opt/helios` on installed systems is not a Git repository.

---

## ISO Testing Workflow

After building:

1. Test the ISO in a VM.
2. Verify installer.
3. Verify first boot.
4. Verify Flex Launcher.
5. Verify applications.
6. Test on physical NUC hardware.

VM success is not final validation.

---

## Common Build Problems

### Missing files in ISO

Check:

`scripts/build-runtime.sh`

### Installer problems

Check:

`live-build/config/bootloaders/`

and:

`live-build/config/preseed/`

### Application problems

Check:

- desktop-files/
- Flex Launcher source
- installed runtime files


---

# Session Log

## 2026-08-02 — Installer, Launcher and First Boot Improvements

### Completed

- Confirmed Helios installer successfully installs the operating system.
- Fixed custom Syslinux installer menu:
  - Removed incorrect unresolved kernel placeholders.
  - Corrected installer paths.
  - Reduced menu width.
  - Removed duplicate submenu arrow.
  - Changed simple install priority from `critical` to `high` so hardware with Wi-Fi can request wireless setup.

### Flex Launcher

Problem:
Desktop applications launched through Flex Launcher were failing.

Investigation:
- Flex Launcher was modified to replace direct desktop `Exec=` execution with `gio launch`.
- This change affected Brave and Update Helios.

Resolution:
- Restored original direct `Exec=` launching behaviour.
- Kept additional launcher diagnostics.

Flex Launcher commit:
`8055e02`

Main repository updated:
`889963d`

### Spotify

Problem:
Spotify was not present after installation.

Cause:
Spotify Flatpak cannot reliably install during the live-build ISO creation process because its extra-data installer requires a normal running system.

Resolution:
- Added first-boot Spotify installation service.
- Runs approximately 15 seconds after startup.
- Requires internet connection.
- Installs Spotify and updates Flatpak applications.
- Runs only once.

Files added:
- `scripts/first-boot-flatpaks.sh`
- `systemd/helios-first-boot-flatpaks.service`
- `systemd/helios-first-boot-flatpaks.timer`

### Current Open Issues

OPEN:
- Verify Brave launches after Flex Launcher rollback.
- Verify Update Helios launches after Flex Launcher rollback.
- Verify Spotify first-boot installation.
- Verify installer menu appearance.
- Verify Wi-Fi setup on physical NUC hardware.
- Add dynamic bottom-centre launcher update notification.

---


## 2026-08-02 — Update Helios Redesign

### Problem

The Update Helios button did not work reliably.

### Previous Design

The update script attempted to run privileged actions directly:

- sudo install.sh
- sudo flatpak install
- sudo flatpak update

This is unsuitable for a TV appliance because the controller interface cannot handle password prompts.

### New Design

Update Helios now uses a controlled system service architecture.

The runtime update mechanism is not yet implemented. The service currently provides the foundation for future Helios runtime updates.

Flow:

Flex Launcher -> helios-update -> systemd service -> helios-update-service (root)

### Changes

Added:

- scripts/helios-update-service.sh
- systemd/helios-update.service
- sudoers/helios-update

Updated:

- scripts/update-helios.sh
- scripts/build-runtime.sh
- scripts/configure-system.sh

The helios user can only start:

systemctl start helios-update.service

without requiring a password.

### Design Rule

Never return Update Helios to a password-based sudo workflow.

Helios is an appliance-style operating system and updates must work directly from the controller interface.

---


---

## 2026-08-02 — Update Architecture Correction

### Discovery

The initial Update Helios service design incorrectly assumed that the installed Helios system contained a Git repository.

### Finding

The installed runtime is created by:

- `scripts/build-runtime.sh`

This intentionally excludes:

- `.git/`
- `.github/`

Therefore:

`/opt/helios`

is a runtime installation only and is not suitable for `git pull` based updates.

### Correction

Do not implement Update Helios using:

- git pull inside `/opt/helios`
- a development repository on the installed NUC

Future update system must use a release/runtime update mechanism.

Current temporary behaviour:

- Update Helios launches a privileged service.
- The service updates Flatpak applications.
- Full Helios runtime update mechanism is still to be designed.
- Implement official Helios runtime update mechanism.

### Important Rule

The development repository:

`~/Projects/project-helios`

and installed runtime:

`/opt/helios`

are separate systems and must not be treated as the same thing.

---


---

## 2026-08-02 — Flex Launcher Status Overlay

### Added

Flex Launcher now supports an optional status message overlay.

Location:

`~/.config/flex-launcher/status.txt`

If the file exists and contains text, Flex Launcher displays the message at the bottom centre of the screen.

### Implementation

Added to Flex Launcher:

- Status texture support.
- Status text loading.
- Bottom-centre rendering.
- Cleanup handling.

Flex Launcher commit:

`1ea02be`

### Intended Use

The status overlay is intended for Helios notifications such as:

- Helios update available.
- Application updates available.
- System status messages.

### Current Limitation

The display system exists, but the Helios update checker that writes status messages is not yet implemented.

---
