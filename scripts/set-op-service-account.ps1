# Saves a 1Password service account token as the user environment variable
# OP_SERVICE_ACCOUNT_TOKEN, so `op` stops asking for Windows Hello.
# Run it yourself in your own PowerShell window. The token is typed into a hidden
# prompt, so it never shows on screen or lands in shell history.
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\set-op-service-account.ps1
#
# Undo:  .\scripts\set-op-service-account.ps1 -Remove

param([switch]$Remove)

if ($Remove) {
    [Environment]::SetEnvironmentVariable('OP_SERVICE_ACCOUNT_TOKEN', $null, 'User')
    'Removed OP_SERVICE_ACCOUNT_TOKEN. Restart the Claude app and any terminals.'
    exit 0
}

$secure = Read-Host -AsSecureString 'Paste the service account token (input is hidden), then press Enter'
$plain = [Runtime.InteropServices.Marshal]::PtrToStringBSTR(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure))

if ($plain -notlike 'ops_*') {
    'That does not look like a service account token (they start with ops_). Nothing saved.'
    exit 1
}

[Environment]::SetEnvironmentVariable('OP_SERVICE_ACCOUNT_TOKEN', $plain, 'User')
$env:OP_SERVICE_ACCOUNT_TOKEN = $plain
Remove-Variable plain, secure

'Saved. Quick check (vault names only):'
op vault list
'Now fully quit and reopen the Claude app so it picks up the change.'
