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
        $resolved = (Resolve-Path -LiteralPath $Link).Path
        $expected = (Resolve-Path -LiteralPath $Target).Path
        if ($resolved -ne $expected) { throw "Junction verification failed: $Link" }
        Write-Output "[CREATED] $Link -> $expected"
    }
}

Assert-Target $AgentSkillsDir
Ensure-Junction (Join-Path $HomeDir '.agents\skills') $AgentSkillsDir
Ensure-Junction (Join-Path $HomeDir '.claude\skills') $AgentSkillsDir
Ensure-Junction (Join-Path $HomeDir '.cursor\skills') $AgentSkillsDir
Ensure-Junction (Join-Path $HomeDir '.opencode\skills') $AgentSkillsDir
Write-Output '[INFO] .codex\skills is not modified; current Codex discovery uses .agents\skills.'

$referenceDir = Join-Path $FullRepoDir 'references'
Ensure-Junction (Join-Path $HomeDir '.agents\references') $referenceDir

if (Test-Path -LiteralPath $NvidiaDir -PathType Container) {
    Write-Output "[INFO] NVIDIA skills detected at $NvidiaDir; no link was changed."
} else {
    Write-Output "[INFO] NVIDIA skills not installed; skipped."
}
Write-Output '[INFO] Gemini uses its native `gemini skills link` registration because the existing .gemini\skills directory contains independent skills.'
