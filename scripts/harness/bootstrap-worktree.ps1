param(
    [Parameter(Mandatory=$true)][string]$TaskId,
    [Parameter(Mandatory=$true)][ValidateSet("impl","review","verify","gui","docs")][string]$Lane,
    [switch]$PrepareRuntime,
    [switch]$InstallDependencies
)

$ErrorActionPreference = "Stop"

function Detect-Stack {
    $stacks = @()
    if (Test-Path "package.json") { $stacks += "node" }
    if (Test-Path "pyproject.toml" -or Test-Path "requirements.txt") { $stacks += "python" }
    if (Test-Path "Cargo.toml") { $stacks += "rust" }
    if ((Get-ChildItem -Path . -Filter "*.sln" -File -ErrorAction SilentlyContinue) -or
        (Get-ChildItem -Path . -Filter "*.csproj" -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1)) {
        $stacks += "dotnet"
    }
    if ($stacks.Count -eq 0) { $stacks += "unknown" }
    return $stacks
}

$stacks = Detect-Stack
Write-Host "[bootstrap] task=$TaskId lane=$Lane"
Write-Host "[bootstrap] detected stacks: $($stacks -join ', ')"

if ($PrepareRuntime) {
    & (Join-Path $PSScriptRoot "gen-worktree-env.ps1") -TaskId $TaskId -Lane $Lane -OutFile ".env.worktree.local"
} else {
    Write-Host "[bootstrap] runtime overlay not created (use -PrepareRuntime if needed)"
}

if ($InstallDependencies) {
    Write-Warning "[bootstrap] explicit dependency installation requested by operator"
    foreach ($stack in $stacks) {
        switch ($stack) {
            "node"   { Write-Host "Run your package-manager install explicitly (npm/pnpm/yarn) according to project policy." }
            "python" { Write-Host "Create/activate the project virtual environment explicitly according to project policy." }
            "rust"   { Write-Host "Run cargo fetch/build explicitly according to project policy." }
            "dotnet" { Write-Host "Run dotnet restore explicitly according to project policy." }
            default  { Write-Host "No known dependency workflow detected." }
        }
    }
} else {
    Write-Host "[bootstrap] no dependency installation performed"
}

Write-Host "[bootstrap] next: update launch.md/status.yaml and begin lane-specific work"
