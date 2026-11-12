# 2026-11-08: A $30 Chromebook becomes a Linux server

**Result:** A used G11 Chromebook I bought for $30 no longer runs ChromeOS at all. It boots
custom firmware straight into CachyOS Linux and now hosts this homelab's Docker stack:
Traefik, a Cloudflare Tunnel, and a public website.

## Why bother

Chromebooks are cheap, quiet, sip power, and get retired by schools in bulk once Google stops
updating them. The hardware is still fine. Replacing Google's firmware turns one into a normal
x86 PC that can run any Linux distribution, for the price of a takeout dinner.

## What it is

| | |
|---|---|
| Price | $30, used |
| Model | G11 Chromebook (Google board name "Snappy") |
| CPU | Intel Celeron N3450, 4 cores, x86_64 |
| Memory | 8 GB (7.6 GB usable) |
| Storage | 55 GB eMMC |
| Network | Wi-Fi only |
| Firmware | MrChromebox UEFI (replaces Google's ChromeOS firmware) |
| OS | CachyOS (Arch-based, rolling release), btrfs with snapper snapshots |

## What I did

1. **Bought it used for $30.**
2. **Replaced the firmware.** Flashed MrChromebox's UEFI firmware, which wipes out
   Google's boot firmware. After that the machine behaves like any other PC: it boots from
   USB and doesn't try to start ChromeOS.
3. **Installed CachyOS**, an Arch-based Linux distribution, over the whole disk. ChromeOS is
   gone completely.
4. **Turned it into a server.** SSH with key login, lid-close and idle sleep turned off,
   Docker and Docker Compose installed, and a folder for each stack under `/opt/stacks`.
5. **Put it to work.** It now runs the reverse proxy and Cloudflare Tunnel from the
   [secrets, proxy and tunnel entry](2026-11-08-secrets-proxy-tunnel.md), and serves a
   small public website without a single open port on the home router.

## Things to know

- **Flashing firmware is the risky step.** Firmware replacement on a Chromebook means turning
  off write protection, and a failed flash can leave the machine unable to boot. Back up
  anything on it first, and follow MrChromebox's documentation for your exact model.
- **CachyOS is a rolling release.** Update on purpose (`sudo pacman -Syu`) and read what's
  changing, rather than updating automatically on a server.
- **btrfs + snapper** means a bad update can be rolled back to an earlier snapshot.
- **Wi-Fi only.** A USB Ethernet adapter would make it steadier as a server.
- **The default shell is fish, not bash.** Run bash scripts with `bash script.sh`.

## What's next

- Reserve the server's address on the router so it never changes.
- Check whether the new firmware can power the machine back on automatically after an outage.
