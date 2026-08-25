[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$testRoot = Join-Path ([IO.Path]::GetTempPath()) ("heru-agent-windows-test-" + [guid]::NewGuid().ToString('N'))

try {
    $geminiSkills = Join-Path $testRoot '.gemini\skills'
    $duplicateName = 'api-and-interface-design'
    $duplicateTarget = Join-Path $repoRoot "skills\$duplicateName"
    $duplicateLink = Join-Path $geminiSkills $duplicateName
    $independentSkill = Join-Path $geminiSkills 'independent-gemini-skill'
    New-Item -ItemType Directory -Force -Path $geminiSkills, $independentSkill | Out-Null
    New-Item -ItemType Junction -Path $duplicateLink -Target $duplicateTarget | Out-Null

    & powershell.exe -NoProfile -File (Join-Path $repoRoot 'setup-universal-agents.ps1') `
        -HomeDir $testRoot `
        -AgentSkillsDir (Join-Path $repoRoot 'skills') `
        -FullRepoDir $repoRoot `
        -NvidiaDir (Join-Path $testRoot 'missing-nvidia')
    if ($LASTEXITCODE -ne 0) { throw "setup-universal-agents.ps1 failed with exit code $LASTEXITCODE" }

    if (Test-Path -LiteralPath $duplicateLink) { throw 'duplicate Gemini junction was not removed' }
    if (-not (Test-Path -LiteralPath $independentSkill -PathType Container)) { throw 'independent Gemini skill was removed' }
    foreach ($relativePath in @('.agents\skills', '.claude\skills', '.cursor\skills', '.opencode\skills')) {
        $item = Get-Item -LiteralPath (Join-Path $testRoot $relativePath) -Force
        if (-not ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) { throw "$relativePath is not a junction" }
        if (([string]$item.Target).TrimEnd('\') -ne (Join-Path $repoRoot 'skills').TrimEnd('\')) { throw "$relativePath has the wrong target" }
    }
    $protectionPreview = & powershell.exe -NoProfile -File (Join-Path $repoRoot 'configure-github-protection.ps1') -WhatIf
    $protectionText = $protectionPreview -join "`n"
    if ($LASTEXITCODE -ne 0 -or $protectionText -notmatch 'WHATIF: would PUT branch protection') {
        throw 'branch-protection WhatIf validation failed'
    }
    Write-Output 'WINDOWS AUTOMATION TEST PASSED'
} finally {
    if (Test-Path -LiteralPath $testRoot) {
        $resolved = (Resolve-Path -LiteralPath $testRoot).Path
        $tempRoot = ([IO.Path]::GetTempPath()).TrimEnd('\')
        if (-not $resolved.StartsWith("$tempRoot\heru-agent-windows-test-", [StringComparison]::OrdinalIgnoreCase)) {
            throw "Refusing to remove unexpected test path: $resolved"
        }
        Remove-Item -LiteralPath $resolved -Recurse -Force
    }
}
