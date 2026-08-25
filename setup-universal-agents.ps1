[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$HomeDir = '',
    [string]$AgentSkillsDir = '',
    [string]$FullRepoDir = '',
    [string]$NvidiaDir = 'D:\nvidia-skills'
)

$ErrorActionPreference = 'Stop'
if (-not $HomeDir) { $HomeDir = [Environment]::GetFolderPath('UserProfile') }
if (-not $FullRepoDir) { $FullRepoDir = Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $AgentSkillsDir) { $AgentSkillsDir = Join-Path $FullRepoDir 'skills' }

function Assert-Target([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        throw "Target directory does not exist: $Path"
    }
}

function Ensure-Junction([string]$Link, [string]$Target) {
    Assert-Target $Target
    if (Test-Path -LiteralPath $Link) {
        $item = Get-Item -LiteralPath $Link -Force
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            $resolved = ([string]$item.Target).TrimEnd('\')
            $expected = (Resolve-Path -LiteralPath $Target).Path.TrimEnd('\')
            if ($resolved -eq $expected) { Write-Output "[OK] $Link -> $expected"; return }
        }
        throw "Existing path is not the expected junction: $Link"
    }
    if ($PSCmdlet.ShouldProcess($Link, "Create junction to $Target")) {
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Link) | Out-Null
        New-Item -ItemType Junction -Path $Link -Target $Target | Out-Null
        $resolved = ([string](Get-Item -LiteralPath $Link -Force).Target).TrimEnd('\')
        $expected = (Resolve-Path -LiteralPath $Target).Path
        if ($resolved -ne $expected) { throw "Junction verification failed: $Link" }
        Write-Output "[CREATED] $Link -> $expected"
    }
}

function Remove-DuplicateGeminiJunctions([string]$GeminiSkillsRoot, [string]$SourceSkillsRoot) {
    if (-not (Test-Path -LiteralPath $GeminiSkillsRoot -PathType Container)) { return }
    foreach ($item in Get-ChildItem -LiteralPath $GeminiSkillsRoot -Directory -Force) {
        if (-not ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) { continue }
        $source = Join-Path $SourceSkillsRoot $item.Name
        if (-not (Test-Path -LiteralPath $source -PathType Container)) { continue }
        $resolved = ([string]$item.Target).TrimEnd('\')
        $expected = (Resolve-Path -LiteralPath $source).Path.TrimEnd('\')
        if ($resolved -ne $expected) { continue }
        if ($PSCmdlet.ShouldProcess($item.FullName, 'Remove duplicate Gemini skill junction')) {
            $item.Delete()
            if (Test-Path -LiteralPath $item.FullName) { throw "Duplicate Gemini junction remains: $($item.FullName)" }
            Write-Output "[REMOVED DUPLICATE] $($item.FullName) -> $expected"
        }
    }
}

Assert-Target $AgentSkillsDir
Ensure-Junction (Join-Path $HomeDir '.agents\skills') $AgentSkillsDir
Ensure-Junction (Join-Path $HomeDir '.claude\skills') $AgentSkillsDir
Ensure-Junction (Join-Path $HomeDir '.cursor\skills') $AgentSkillsDir
Ensure-Junction (Join-Path $HomeDir '.opencode\skills') $AgentSkillsDir
Write-Output '[INFO] .codex\skills is not modified; current Codex discovery uses .agents\skills.'
Remove-DuplicateGeminiJunctions (Join-Path $HomeDir '.gemini\skills') $AgentSkillsDir

$referenceDir = Join-Path $FullRepoDir 'references'
Ensure-Junction (Join-Path $HomeDir '.agents\references') $referenceDir

if (Test-Path -LiteralPath $NvidiaDir -PathType Container) {
    Write-Output "[INFO] NVIDIA skills detected at $NvidiaDir; no link was changed."
} else {
    Write-Output "[INFO] NVIDIA skills not installed; skipped."
}
Write-Output '[INFO] Gemini discovers shared skills through .agents\skills; independent .gemini\skills entries are preserved.'
