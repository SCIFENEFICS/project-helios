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

(TODO - complete in next update.)

# 5. Build Process

(TODO - complete in next update.)
