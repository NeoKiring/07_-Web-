param(
    [Parameter(Mandatory=$true)][string]$TaskId,
    [Parameter(Mandatory=$true)][string]$Lane,
    [string]$RegistryPath = ".runtime/allocations.json",
    [int]$BaseAppPort = 4100,
    [int]$BaseApiPort = 5100,
    [int]$BaseDbPort  = 6100
)

$ErrorActionPreference = "Stop"

function Ensure-Dir([string]$PathValue) {
    $dir = Split-Path -Parent $PathValue
    if ($dir -and -not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

function With-Lock([scriptblock]$Action, [string]$LockPath) {
    Ensure-Dir $LockPath
    for ($i = 0; $i -lt 50; $i++) {
        try {
            $fs = [System.IO.File]::Open($LockPath, [System.IO.FileMode]::OpenOrCreate, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
            try { return & $Action }
            finally { $fs.Dispose() }
        } catch {
            Start-Sleep -Milliseconds 100
        }
    }
    throw "Failed to acquire runtime allocation lock: $LockPath"
}

function Get-Registry([string]$PathValue) {
    if (-not (Test-Path $PathValue)) {
        Ensure-Dir $PathValue
        @{ version = 1; allocations = @() } | ConvertTo-Json -Depth 8 | Set-Content -Path $PathValue -Encoding UTF8
    }
    $raw = Get-Content -Path $PathValue -Raw -Encoding UTF8
    if ([string]::IsNullOrWhiteSpace($raw)) {
        return @{ version = 1; allocations = @() }
    }
    return ($raw | ConvertFrom-Json -AsHashtable)
}

function Save-Registry([string]$PathValue, [hashtable]$Registry) {
    $Registry | ConvertTo-Json -Depth 8 | Set-Content -Path $PathValue -Encoding UTF8
}

$lockPath = [System.IO.Path]::ChangeExtension($RegistryPath, ".lock")

$result = With-Lock -LockPath $lockPath -Action {
    $registry = Get-Registry -PathValue $RegistryPath
    $existing = $registry.allocations | Where-Object { $_.task_id -eq $TaskId -and $_.lane -eq $Lane } | Select-Object -First 1
    if ($null -ne $existing) { return $existing }

    $index = 0
    while ($true) {
        $appPort = $BaseAppPort + $index
        $apiPort = $BaseApiPort + $index
        $dbPort  = $BaseDbPort  + $index

        $collision = $registry.allocations | Where-Object {
            $_.app_port -eq $appPort -or $_.api_port -eq $apiPort -or $_.db_port -eq $dbPort
        } | Select-Object -First 1

        if ($null -eq $collision) {
            $safeId = "$TaskId`_$Lane"
            $entry = [ordered]@{
                task_id = $TaskId
                lane = $Lane
                app_port = $appPort
                api_port = $apiPort
                db_port = $dbPort
                app_instance_id = "$TaskId-$Lane"
                user_data_dir = ".runtime/userdata/$safeId"
                log_dir = ".runtime/logs/$safeId"
                tmp_dir = ".runtime/tmp/$safeId"
                allocated_at = (Get-Date).ToString("s")
            }
            foreach ($dir in @($entry.user_data_dir, $entry.log_dir, $entry.tmp_dir)) {
                New-Item -ItemType Directory -Path $dir -Force | Out-Null
            }
            $registry.allocations = @($registry.allocations + $entry)
            Save-Registry -PathValue $RegistryPath -Registry $registry
            return $entry
        }

        $index++
        if ($index -gt 500) { throw "No runtime port allocation available" }
    }
}

$result | ConvertTo-Json -Depth 6
