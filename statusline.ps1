# Claude Code statusLine for Windows (PowerShell)
# Format: Opus 4.7 (high) · /cwd · 5h 45% · wk 23% · Context 20% used

$payload = [Console]::In.ReadToEnd()
if (-not $payload.Trim()) { exit 0 }

try { $json = $payload | ConvertFrom-Json } catch { exit 0 }

$DIR    = if ($json.workspace.current_dir) { $json.workspace.current_dir } elseif ($json.cwd) { $json.cwd } else { $null }
$MODEL  = $json.model.display_name
$CTX    = if ($null -ne $json.context_window.used_percentage) { [int]$json.context_window.used_percentage } else { $null }
$PCT_5H = if ($null -ne $json.rate_limits.five_hour.used_percentage) { [int]$json.rate_limits.five_hour.used_percentage } else { $null }
$PCT_WK = if ($null -ne $json.rate_limits.seven_day.used_percentage) { [int]$json.rate_limits.seven_day.used_percentage } else { $null }

$EFFORT = $env:CLAUDE_EFFORT
if (-not $EFFORT) { $EFFORT = $env:CLAUDECODE_EFFORT }
if (-not $EFFORT) { $EFFORT = $env:CLAUDE_CODE_EFFORT }
if (-not $EFFORT) {
    $sp = Join-Path $env:USERPROFILE ".claude\settings.json"
    if (Test-Path $sp) {
        try { $EFFORT = (Get-Content $sp -Raw | ConvertFrom-Json).effort } catch {}
    }
}

$ESC    = [char]27
$DIM    = "$ESC[2m"
$RESET  = "$ESC[0m"
$CYAN   = "$ESC[36m"
$YELLOW = "$ESC[33m"
$RED    = "$ESC[31m"
$GREEN  = "$ESC[32m"

$ctx_color = $GREEN
if ($null -ne $CTX) {
    if    ($CTX -ge 80) { $ctx_color = $RED }
    elseif ($CTX -ge 50) { $ctx_color = $YELLOW }
}

$pct_5h_color = $GREEN
if ($null -ne $PCT_5H) {
    if    ($PCT_5H -ge 90) { $pct_5h_color = $RED }
    elseif ($PCT_5H -ge 70) { $pct_5h_color = $YELLOW }
}

$pct_wk_color = $GREEN
if ($null -ne $PCT_WK) {
    if    ($PCT_WK -ge 85) { $pct_wk_color = $RED }
    elseif ($PCT_WK -ge 60) { $pct_wk_color = $YELLOW }
}

$SEP   = " $DIM·$RESET "
$parts = [System.Collections.Generic.List[string]]::new()

if ($MODEL) {
    if ($EFFORT) { $parts.Add("${MODEL} ${DIM}(${EFFORT})${RESET}") }
    else         { $parts.Add($MODEL) }
}
if ($DIR) { $parts.Add("${CYAN}${DIR}${RESET}") }

if ($null -ne $PCT_5H -or $null -ne $PCT_WK) {
    $credits = ""
    if ($null -ne $PCT_5H) { $credits = "${DIM}5h${RESET} ${pct_5h_color}${PCT_5H}%${RESET}" }
    if ($null -ne $PCT_WK) {
        if ($credits) { $credits += " ${DIM}/${RESET} " }
        $credits += "${DIM}wk${RESET} ${pct_wk_color}${PCT_WK}%${RESET}"
    }
    $parts.Add($credits)
}

if ($null -ne $CTX) { $parts.Add("${DIM}Context${RESET} ${ctx_color}${CTX}%${RESET} ${DIM}used${RESET}") }

[Console]::WriteLine($parts -join $SEP)
