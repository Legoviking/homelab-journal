# Read-only check of the Cloudflare DNS token stored in 1Password.
# Run with:  .\scripts\test-cloudflare-token.ps1
# The token is injected by `op run` and never printed or written to disk.

if (-not $env:CF_API_TOKEN -or $env:CF_API_TOKEN -like 'op://*') {
    $env:CF_API_TOKEN = 'op://Homelab/Cloudflare DNS token/credential'
    op run '--' powershell -NoProfile -ExecutionPolicy Bypass -File $PSCommandPath
    exit $LASTEXITCODE
}

$headers = @{ Authorization = "Bearer $env:CF_API_TOKEN" }
$api = 'https://api.cloudflare.com/client/v4'

try {
    $v = Invoke-RestMethod -Uri "$api/user/tokens/verify" -Headers $headers
    "Token verify: success=$($v.success) status=$($v.result.status) expires=$($v.result.expires_on)"
} catch {
    "Token verify FAILED: $($_.Exception.Message)"
    exit 1
}

try {
    $z = Invoke-RestMethod -Uri "$api/zones?name=example.com" -Headers $headers
    if ($z.result.Count -eq 0) { "Zone check: token cannot see example.com"; exit 1 }
    foreach ($r in $z.result) { "Zone check: $($r.name) status=$($r.status)" }
    $d = Invoke-RestMethod -Uri "$api/zones/$($z.result[0].id)/dns_records?per_page=1" -Headers $headers
    "DNS read: success=$($d.success) (records visible: $($d.result_info.total_count))"
} catch {
    "Zone/DNS check FAILED: $($_.Exception.Message)"
    exit 1
}
