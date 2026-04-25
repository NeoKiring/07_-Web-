param(
    [Parameter(Mandatory=$true)][string]$TaskId,
    [Parameter(Mandatory=$true)][string]$Area,
    [Parameter(Mandatory=$true)][string]$Slug,
    [string]$BaseBranch = "main"
)

$ErrorActionPreference = "Stop"

$branch = "ai/$Area/$TaskId-$Slug"
$worktree = ".worktrees/${TaskId}__impl"

git worktree add -b $branch $worktree $BaseBranch
Write-Host "Created writable implementation lane"
Write-Host "branch: $branch"
Write-Host "worktree: $worktree"
