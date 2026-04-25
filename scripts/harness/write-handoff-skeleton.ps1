param(
    [Parameter(Mandatory=$true)][string]$TaskId,
    [Parameter(Mandatory=$true)][string]$Lane,
    [string]$Tool = "",
    [string]$HeadCommit = ""
)

$ErrorActionPreference = "Stop"

$outDir = "docs/ai/tasks/$TaskId"
$outFile = Join-Path $outDir "handoff.md"
New-Item -ItemType Directory -Path $outDir -Force | Out-Null

if (-not (Test-Path $outFile)) {
@"
# Handoff: $TaskId

## Status snapshot
- state:
- current lane: $Lane
- tool: $Tool
- head commit: $HeadCommit
- safe to merge now: no

## Objective

## Changed files
- none yet

## Commands run
- ...

## Results
- ...

## Current blocker / remaining work
- ...

## Exact next action
- ...

## Merge safety
- rollback path:
- serial-only concern:
- runtime concern:
"@ | Set-Content -Path $outFile -Encoding UTF8
}

Write-Host "Ensured $outFile"
