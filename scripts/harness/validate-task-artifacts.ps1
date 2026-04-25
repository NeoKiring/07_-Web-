param(
    [Parameter(Mandatory=$true)][string]$TaskId,
    [switch]$RequireMergeReady
)

$ErrorActionPreference = "Stop"

$taskDir = "docs/ai/tasks/$TaskId"
$status = Join-Path $taskDir "status.yaml"
$contract = Join-Path $taskDir "contract.md"
$handoff = Join-Path $taskDir "handoff.md"
$review = Join-Path $taskDir "review.md"
$verify = Join-Path $taskDir "verify.md"
$gui = Join-Path $taskDir "gui.md"

$errors = New-Object System.Collections.Generic.List[string]

foreach ($path in @($status, $contract, $handoff)) {
    if (-not (Test-Path $path)) { $errors.Add("Missing required artifact: $path") }
}

if (Test-Path $status) {
    $statusText = Get-Content -Path $status -Raw -Encoding UTF8
    foreach ($required in @('task_id:', 'state:', 'current_lane:', 'implementation_branch:', 'head_commit:', 'exact_next_action:', 'last_updated:')) {
        if ($statusText -notmatch [regex]::Escape($required)) {
            $errors.Add("status.yaml missing field: $required")
        }
    }
    $state = if ($statusText -match 'state:\s*(.+)') { $Matches[1].Trim() } else { "" }
    $guiStatus = if ($statusText -match 'gui_status:\s*(.+)') { $Matches[1].Trim() } else { "" }
    $reviewVerdict = if ($statusText -match 'review_verdict:\s*(.+)') { $Matches[1].Trim() } else { "" }
    $verifyStatus = if ($statusText -match 'verify_status:\s*(.+)') { $Matches[1].Trim() } else { "" }

    if ($RequireMergeReady -or $state -eq 'merge-ready') {
        if (-not (Test-Path $review)) { $errors.Add("merge-ready requires review.md") }
        if (-not (Test-Path $verify)) { $errors.Add("merge-ready requires verify.md") }
        if ($reviewVerdict -notin @('PASS','PASS-WITH-NOTES')) {
            $errors.Add("merge-ready requires review_verdict PASS or PASS-WITH-NOTES")
        }
        if ($verifyStatus -notin @('pass','partial-pass','verified-pass')) {
            $errors.Add("merge-ready requires verify_status pass-like value")
        }
        if ($guiStatus -eq 'required' -and -not (Test-Path $gui)) {
            $errors.Add("merge-ready with gui_status=required requires gui.md or explicit defer in status")
        }
    }
}

if (Test-Path $contract) {
    $contractText = Get-Content -Path $contract -Raw -Encoding UTF8
    foreach ($needle in @('## Objective','## In scope','## Out of scope','## Touched files','## Forbidden files','## Verification commands','## GUI verification','## Runtime isolation','## Done definition')) {
        if ($contractText -notmatch [regex]::Escape($needle)) {
            $errors.Add("contract.md missing section: $needle")
        }
    }
}

if ($errors.Count -gt 0) {
    Write-Host "Artifact validation FAILED for $TaskId"
    $errors | ForEach-Object { Write-Host "- $_" }
    exit 1
}

Write-Host "Artifact validation PASSED for $TaskId"
