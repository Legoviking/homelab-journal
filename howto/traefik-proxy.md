# Traefik reverse proxy on the Chromebook 

Config: `stacks/proxy/` in this repo.
On the Chromebook it lives in `/opt/stacks/proxy/`.

| File on Chromebook | What it is | In git? |
|---|---|---|
| `compose.yaml` | Traefik + whoami test app, `proxy` network | yes |
| `traefik.yml` | Entry points (80 -> 443 redirect), Docker + file providers, Let's Encrypt via Cloudflare DNS | yes |
| `conf.d/` | One file per non-Docker site | yes |
| `secrets/cf_dns_token` | Cloudflare DNS token, chmod 600, folder 700 | **no** |
| `letsencrypt/acme.json` | Let's Encrypt account + certificates | **no** |

Traefik reads the token from the Docker secret via `CF_DNS_API_TOKEN_FILE`, so it never
appears in `compose.yaml`, `.env` or `docker inspect`.

## Deploy a config change

```powershell
scp .\stacks\proxy\compose.yaml .\stacks\proxy\traefik.yml chromebook:/opt/stacks/proxy/
ssh chromebook "cd /opt/stacks/proxy; docker compose up -d"
```

`traefik.yml` changes need `docker compose up -d --force-recreate traefik`.

## Write or replace the token (from 1Password, never shown)

```powershell
cmd /c "op read op://Homelab/<dns-token-item-id>/credential | ssh chromebook ""umask 077; mkdir -p /opt/stacks/proxy/secrets; env LC_ALL=C tr -cd '[:graph:]' > /opt/stacks/proxy/secrets/cf_dns_token"""
ssh chromebook "cd /opt/stacks/proxy; docker compose up -d --force-recreate traefik"
```

`cmd /c` is used because Windows PowerShell 5.1 adds characters when piping to programs.
`tr` strips any stray newline or BOM. Check the result with
`ssh chromebook "stat -c '%a %s' /opt/stacks/proxy/secrets/cf_dns_token"`: expect `600 53`.

## Check the certificate

From the PC (no DNS needed, Windows checks the cert):

```powershell
curl.exe -sS --resolve hello.example.com:443:<server-lan-ip> https://hello.example.com
```

On the Chromebook: `echo | openssl s_client -connect 127.0.0.1:443 -servername hello.example.com 2>/dev/null | openssl x509 -noout -issuer -enddate`

First real cert: issuer Let's Encrypt YR2, expires 2027-02-06. Traefik renews ~30 days before.

## Staging first for risky changes

Add `caServer: https://acme-staging-v02.api.letsencrypt.org/directory` under
`certificatesResolvers.letsencrypt.acme`, delete `letsencrypt/acme.json`, recreate Traefik.
Undo the same way. Staging certs show issuer `(STAGING) ...` and browsers won't trust them.

## Gotchas

- The Chromebook login shell is fish. Send bash scripts with `scp` and run
  `ssh chromebook bash /path/script.sh`, or pipe them to `ssh chromebook bash -s`
  (PowerShell adds a BOM and `\r` to the first and last line; harmless but noisy).
- `hello.example.com` has no DNS record yet, so a browser can't find it. Step 3 (tunnel)
  publishes it; split DNS (router/AdGuard) would point home devices at <server-lan-ip>.
- The Traefik dashboard is off on purpose.

## Cloudflare Tunnel 

- Tunnel `chromebook`, remotely managed: Cloudflare dashboard > Networking > Tunnels.
- The dashboard **masks the token** in the install command (`eyJhIjoi****...`). Click the
  eye/reveal icon before copying. Pasting the whole `docker run ... --token eyJ...` command
  into the 1Password credential field is fine.
- Copy it to the Chromebook (keeps only the `eyJ...` part, chmod 600, prints the length):

  ```powershell
  cmd /c "op read op://Homelab/<tunnel-token-item-id>/credential | ssh chromebook bash /opt/stacks/proxy/bin/save-tunnel-token.sh"
  ssh chromebook "cd /opt/stacks/proxy; docker compose up -d --force-recreate cloudflared"
  ```

- cloudflared runs as uid 1000 so it can read the token file.
- Add a public site: tunnel > Routes > Add route > Published application. Service
  `https://traefik:443`, **Additional settings > TLS > Match SNI to host: on**. Leave TLS
  verification on. Cloudflare creates the DNS CNAME itself. Never point a route at port 80.
- Check: `curl.exe -sS -D - https://<host>` shows `Server: cloudflare` and a `CF-RAY` header.

To take a site offline, delete its route in the dashboard; that also removes its CNAME.

## Rollback

```powershell
ssh chromebook "cd /opt/stacks/proxy; docker compose down"
```

This stops everything and frees ports 80/443. Config, token and certs stay in the folder.
To remove the token too: `ssh chromebook "rm /opt/stacks/proxy/secrets/cf_dns_token"`.
