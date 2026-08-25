[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$InstallRoot = $PSScriptRoot,
    [string]$HomeDir = ([Environment]::GetFolderPath('UserProfile'))
)

$ErrorActionPreference = 'Stop'
$registryPath = 'HKCU:\Software\HeruAgentSkills'
$updater = Join-Path $InstallRoot 'update-agent-skills.ps1'
$setupLinks = Join-Path $InstallRoot 'setup-universal-agents.ps1'
$setupTask = Join-Path $InstallRoot 'setup-task.ps1'

foreach ($file in @($updater, $setupLinks, $setupTask)) {
    if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { throw "Required file not found: $file" }
}

if ($PSCmdlet.ShouldProcess($registryPath, 'Write per-user agent skills configuration')) {
    New-Item -Path $registryPath -Force | Out-Null
    New-ItemProperty -Path $registryPath -Name InstallRoot -Value $InstallRoot -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $registryPath -Name SkillsRoot -Value (Join-Path $InstallRoot 'skills') -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $registryPath -Name Updater -Value $updater -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $registryPath -Name SchemaVersion -Value 1 -PropertyType DWord -Force | Out-Null
}

if ($PSCmdlet.ShouldProcess('agent discovery links', 'Create and verify junctions')) {
    & powershell.exe -NoProfile -File $setupLinks -HomeDir $HomeDir -AgentSkillsDir (Join-Path $InstallRoot 'skills') -FullRepoDir $InstallRoot
    if ($LASTEXITCODE -ne 0) { throw "Link setup failed with exit code $LASTEXITCODE" }
}

Write-Output '[INFO] Gemini discovers shared skills through .agents\skills; duplicate direct junctions are removed while independent Gemini skills are preserved.'

if ($PSCmdlet.ShouldProcess('AutoUpdateAgentSkills', 'Register weekly update task')) {
    & powershell.exe -NoProfile -File $setupTask
    if ($LASTEXITCODE -ne 0) { throw "Task setup failed with exit code $LASTEXITCODE" }
}

Write-Output "Windows agent skills configuration installed at $registryPath"
