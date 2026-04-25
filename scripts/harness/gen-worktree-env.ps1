param(
    [Parameter(Mandatory=$true)][string]$TaskId,
    [Parameter(Mandatory=$true)][string]$Lane,
    [string]$OutFile = ".env.worktree.local"
)

$ErrorActionPreference = "Stop"

$allocator = Join-Path $PSScriptRoot "alloc-runtime.ps1"
$json = & $allocator -TaskId $TaskId -Lane $Lane
$alloc = $json | ConvertFrom-Json

$dir = Split-Path -Parent $OutFile
if ($dir -and -not (Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}

@"
# Generated worktree-local overlay
TASK_ID=$TaskId
LANE=$Lane
APP_PORT=$($alloc.app_port)
API_PORT=$($alloc.api_port)
DB_PORT=$($alloc.db_port)
APP_INSTANCE_ID=$($alloc.app_instance_id)
USER_DATA_DIR=$($alloc.user_data_dir)
LOG_DIR=$($alloc.log_dir)
TMP_DIR=$($alloc.tmp_dir)
"@ | Set-Content -Path $OutFile -Encoding UTF8

Write-Host "Generated $OutFile"
