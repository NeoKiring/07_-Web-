param(
    [Parameter(Mandatory=$true)][string]$TaskId
)

$ErrorActionPreference = "Stop"

$taskDir = "docs/ai/tasks/$TaskId"
$status = Join-Path $taskDir "status.yaml"
$handoff = Join-Path $taskDir "handoff.md"
$review = Join-Path $taskDir "review.md"
$verify = Join-Path $taskDir "verify.md"

Write-Host "Task bundle: $TaskId"
foreach ($path in @($status, $handoff, $review, $verify)) {
    if (Test-Path $path) {
        Write-Host "- present: $path"
    } else {
        Write-Host "- missing: $path"
    }
}

if (Test-Path $status) {
    Write-Host ""
    Get-Content -Path $status -Encoding UTF8 | Select-Object -First 40
}
