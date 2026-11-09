# Homelab Journal

A beginner's homelab, built one small step at a time with help from Claude Code.
Each journal entry says what was built, why, what went wrong, and how to undo it.

**Goal:** an automated indoor garden (lights, temperature, humidity, air flow) controlled
from a phone or PC, plus a small self-hosted website, all running locally where possible.

## Journal

| Date | Entry |
|---|---|
| 2026-11-08 | [Secrets in 1Password, a reverse proxy with real HTTPS, and a public site with no open ports](journal/2026-11-08-secrets-proxy-tunnel.md) |

## What's in this repo

| Folder | What it holds |
|---|---|
| `journal/` | Dated write-ups, in plain language |
| `howto/` | Repeatable steps (setup, checks, rollback) |
| `stacks/proxy/` | Docker Compose stack: Traefik, cloudflared, a test app |
| `scripts/` | Small helper scripts for Windows PowerShell |
| `recap/` | A standalone illustrated recap page (open in any browser) |

## Rules this repo follows

- **No secrets, ever.** Tokens and passwords live in a password manager. Config files point
  at them; they never contain them.
- **No identifying details.** Domains are `example.com`, addresses are placeholders such
  as `<server-lan-ip>`. Swap in your own values when following along.
- **Snapshot or back up before every change**, and write down how to roll back.
- **One change at a time.** Test it, then move on.

## Stack so far

Docker on a repurposed Chromebook running Linux · Traefik v3 · Let's Encrypt (DNS challenge)
· Cloudflare free plan + Cloudflare Tunnel · 1Password (with a scoped service account)
