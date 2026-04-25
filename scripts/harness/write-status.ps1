param(
    [Parameter(Mandatory=$true)][string]$TaskId,
    [string]$State = "planned",
    [string]$Lane = "",
    [string]$Tool = "",
    [string]$Branch = "",
    [string]$ImplWorktree = "",
    [string]$HeadCommit = "",
    [string]$ExactNextAction = ""
)

$ErrorActionPreference = "Stop"

$outDir = "docs/ai/tasks/$TaskId"
$outFile = Join-Path $outDir "status.yaml"
New-Item -ItemType Directory -Path $outDir -Force | Out-Null

if (-not (Test-Path $outFile)) {
@"
task_id: $TaskId
title: ""
area: ""
slug: ""
batch_id: ""
state: $State
harness_version: 4.0.0-p0

tool: $Tool
current_lane: $Lane
owner: ""

implementation_branch: $Branch
impl_worktree: $ImplWorktree
inspection_worktree: ""
head_commit: $HeadCommit

review_verdict: pending
verify_status: pending
gui_status: not-required
runtime_status: not-started

blocked_reason: ""
exact_next_action: $ExactNextAction
last_updated: $(Get-Date -Format s)
"@ | Set-Content -Path $outFile -Encoding UTF8
} else {
    $content = Get-Content -Path $outFile -Raw -Encoding UTF8
    $replacements = [ordered]@{
        'state: .*' = "state: $State"
        'tool: .*' = "tool: $Tool"
        'current_lane: .*' = "current_lane: $Lane"
        'implementation_branch: .*' = "implementation_branch: $Branch"
        'impl_worktree: .*' = "impl_worktree: $ImplWorktree"
        'head_commit: .*' = "head_commit: $HeadCommit"
        'exact_next_action: .*' = "exact_next_action: $ExactNextAction"
        'last_updated: .*' = "last_updated: $(Get-Date -Format s)"
    }
    foreach ($pair in $replacements.GetEnumerator()) {
        $content = [regex]::Replace($content, $pair.Key, $pair.Value)
    }
    Set-Content -Path $outFile -Value $content -Encoding UTF8
}

Write-Host "Updated $outFile"
