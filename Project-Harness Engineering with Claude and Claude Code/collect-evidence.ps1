$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$evidence = Join-Path $PSScriptRoot 'evidence'
$claims = Join-Path $root 'Build a Claims Intake Agent with a stop_reason-Driven Loop\exercises\03-dynamic-decomposition\solution'
$retail = Join-Path $root 'Engineer a Long-Conversation Context Strategy for a Retail Support Copilot\04-assemble-and-locate\solution'
$config = Join-Path $root 'Configure Claude Code for a Multi-Surface Monorepo Team\04-plan-mode-and-explore-decision-doc\solution'
$monitor = Join-Path $root 'Build a Multi-Shift Quality Monitoring System with Claude Orchestration\04-fork-scratchpad\solution'
$systems = @(
    @{ Name = 'system-1-claims'; Source = $claims; Python = "$env:LOCALAPPDATA\venvs\claims-intake\Scripts\python.exe" }
    @{ Name = 'system-2-retail'; Source = $retail; Python = "$env:LOCALAPPDATA\venvs\retail-context\Scripts\python.exe" }
    @{ Name = 'system-3-config'; Source = $config; Python = (Join-Path $config '.venv\Scripts\python.exe') }
    @{ Name = 'system-4-monitor'; Source = $monitor; Python = (Join-Path $monitor '.venv\Scripts\python.exe') }
)
foreach ($system in $systems) {
    Push-Location $system.Source
    try {
        Write-Output $system.Name
        & $system.Python -m pytest tests/ -v -o 'addopts=' --color=no 2>&1 |
            Tee-Object -FilePath (Join-Path $evidence ($system.Name + '\tests.log')) |
            Select-Object -Last 3
        Write-Output "Test exit code: $LASTEXITCODE"
        if ($LASTEXITCODE -ne 0) {
            throw "Test verification failed for $($system.Name)"
        }
    } finally {
        Pop-Location
    }
}
Copy-Item -LiteralPath (Join-Path $claims 'runs\20261026_171247') -Destination (Join-Path $evidence 'system-1-claims') -Recurse -Force
Copy-Item -LiteralPath (Join-Path $retail 'runs\20261026-142551') -Destination (Join-Path $evidence 'system-2-retail') -Recurse -Force
Copy-Item -LiteralPath (Join-Path $config '.claude') -Destination (Join-Path $evidence 'system-3-config') -Recurse -Force
Copy-Item -LiteralPath (Join-Path $config 'CLAUDE.md') -Destination (Join-Path $evidence 'system-3-config\CLAUDE.md') -Force
Copy-Item -LiteralPath (Join-Path $config 'src') -Destination (Join-Path $evidence 'system-3-config') -Recurse -Force
Copy-Item -LiteralPath (Join-Path $config 'docs') -Destination (Join-Path $evidence 'system-3-config') -Recurse -Force
Copy-Item -LiteralPath (Join-Path $monitor 'data') -Destination (Join-Path $evidence 'system-4-monitor') -Recurse -Force
Push-Location $config
try {
    & '.\.venv\Scripts\python.exe' -m ecommerce_team_config . 2>&1 |
        Tee-Object -FilePath (Join-Path $evidence 'system-3-config\validator.log')
    Write-Output "Validator exit code: $LASTEXITCODE"
} finally {
    Pop-Location
}
Push-Location $monitor
try {
    & (Join-Path $monitor '.venv\Scripts\python.exe') -c "import json; from pathlib import Path; from shift_monitor.warm import WarmStore; store = WarmStore(Path('data/warm.sqlite')); print(json.dumps({'hot_state_bytes': Path('data/hot_state.json').stat().st_size, 'warm_total': store.count(), 'defects_since': len(store.defects_since('2026-04-01T00:00:00Z', limit=1000)), 'since': '2026-04-01T00:00:00Z'}, indent=2))" |
        Tee-Object -FilePath (Join-Path $evidence 'system-4-monitor\metrics.json')
    if ($LASTEXITCODE -ne 0) {
        throw 'Monitor metrics collection failed'
    }
} finally {
    Pop-Location
}