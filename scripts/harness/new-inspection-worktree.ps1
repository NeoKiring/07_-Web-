param(
    [Parameter(Mandatory=$true)][string]$TaskId,
    [Parameter(Mandatory=$true)][ValidateSet("review","verify","gui","docs")][string]$Lane,
    [Parameter(Mandatory=$true)][string]$Commit
)

$ErrorActionPreference = "Stop"

$short = if ($Commit.Length -gt 7) { $Commit.Substring(0,7) } else { $Commit }
$worktree = ".worktrees/${TaskId}__${Lane}__${short}"

git worktree add --detach $worktree $Commit
Write-Host "Created detached inspection lane"
Write-Host "lane: $Lane"
Write-Host "target commit: $Commit"
Write-Host "worktree: $worktree"
