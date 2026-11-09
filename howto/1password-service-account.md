# 1Password service account for Claude (no PIN prompts)

The desktop-app CLI integration asks for Windows Hello for every new process, and each
command Claude runs is a new process. A service account removes the prompt. It can only
see the vaults you grant it (here: Homelab only), never Personal.

Risk accepted: any program running as your Windows user on this PC can read the token
from the environment and use it on the Homelab vault.

## 1. Create the service account (you)

1. Sign in at https://my.1password.com, open **Developer** in the sidebar, then
   **Directory > Service Account** (or **Infrastructure Secrets > Other > Create a Service Account**).
2. Name: `claude-homelab-pc`.
3. Vault access: **Homelab** only, with **Read** and **Write**. Do not add Personal.
   Vault access can't be changed later; you'd make a new service account instead.
4. Create it. The token (starts with `ops_`) is shown once. Click **Save in 1Password**
   (put it in Personal, not Homelab), and copy it.

## 2. Save it on this PC (you)

In your own PowerShell window, in the repo folder:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\set-op-service-account.ps1
```

Paste the token at the hidden prompt. It should list only the Homelab vault.
Then fully quit and reopen the Claude app. Closing the window isn't enough, because the
app keeps running in the system tray: right-click the tray icon and choose **Quit**.
Use the full script path if your terminal isn't in the repo folder.

## 3. Verify (Claude)

`op vault list` runs with no Windows Hello prompt and shows only Homelab.

## Rollback

- On this PC: run the script with `-Remove`, then restart the Claude app. `op` goes back to
  the desktop-app integration (Windows Hello prompts).
- If the token leaks: my.1password.com > Developer > the service account > **Revoke**.
