# Set up 1Password and store the Cloudflare DNS token

The app and CLI are installed with winget (`AgileBits.1Password`, `AgileBits.1Password.CLI`).
Secrets never go in chat, this repo, or a terminal command.

## 1. Account (you)

1. Sign up at https://1password.com (Individual plan, 14-day trial, then ~$36/yr).
2. Save the **Emergency Kit** PDF. It holds your Secret Key. Print it or keep it offline.
   Without it you can't sign in on a new device.
3. Open the 1Password desktop app and sign in. Turn on Windows Hello unlock if it offers.

## 2. Connect the CLI (you)

In the app, open **Settings > Developer** and turn on **Integrate with 1Password CLI**.
This lets `op` (and Claude, running `op`) use the app's unlock. You approve each session
with Windows Hello.

## 3. Vault for homelab secrets (you)

Create a vault named **Homelab**. Later, a service account can be limited to this vault only.

## 4. Cloudflare token (you)

1. Cloudflare dashboard > profile icon > **My Profile > API Tokens > Create Token**.
2. Template **Edit zone DNS**. Zone Resources: **Include > Specific zone > example.com**.
   Permissions stay **Zone > DNS > Edit**. Nothing else.
3. Create it, then copy the token. Cloudflare shows it only once.
4. In 1Password, open the **Homelab** vault and choose **New Item > API Credential**:
   - Title: `Cloudflare DNS token`
   - credential: paste the token
   - hostname: `api.cloudflare.com`
5. Save it. Clear your clipboard by copying something else.

## 5. Verify (Claude)

`op item list --vault Homelab` lists only item titles. It must show the item, and no secret
is printed. Later, `.env` files reference the token as
`op://Homelab/Cloudflare DNS token/credential` instead of holding it.

To check the token still works (read-only, token never printed):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\test-cloudflare-token.ps1
```

Expected: `success=True status=active`, `Zone check: example.com status=active`, `DNS read: success=True`.
Note: in Windows PowerShell 5.1, quote the separator as `op run '--' ...` or `op` won't see it.

## Rollback

Delete the token in Cloudflare (My Profile > API Tokens > Roll or Delete) if it ever leaks,
then create a new one and replace the credential field.
