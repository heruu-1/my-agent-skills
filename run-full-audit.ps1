[CmdletBinding()]
param(
    [string]$RepoPath = '',
    [string]$HomeDir = ([Environment]::GetFolderPath('UserProfile')),
    [string]$TaskName = 'AutoUpdateAgentSkills'
)

$ErrorActionPreference = 'Stop'
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $RepoPath) { $RepoPath = $scriptRoot }
$expectedSkills = (Resolve-Path -LiteralPath (Join-Path $RepoPath 'skills') -ErrorAction SilentlyContinue).Path
$expectedUpdater = Join-Path $RepoPath 'update-agent-skills.ps1'
$failures = [System.Collections.Generic.List[string]]::new()
function Check([string]$Name, [scriptblock]$Action) {
    try { & $Action; Write-Output "[PASS] $Name" }
    catch { $failures.Add("${Name}: $($_.Exception.Message)"); Write-Output "[FAIL] ${Name}: $($_.Exception.Message)" }
}

Write-Output "Read-only audit for $RepoPath"
Check 'repository exists' { if (-not (Test-Path -LiteralPath $RepoPath -PathType Container)) { throw 'missing' } }
Check 'working tree clean' {
    $s = & git -C $RepoPath status --porcelain=v1
    if ($s) { throw "dirty working tree: $s" }
}
Check 'skills directory exists' { if (-not (Test-Path -LiteralPath (Join-Path $RepoPath 'skills') -PathType Container)) { throw 'missing' } }
Check 'universal junctions resolve' {
    foreach ($path in @('.agents\skills','.claude\skills','.cursor\skills','.opencode\skills')) {
        $link = Join-Path $HomeDir $path
        if (-not (Test-Path -LiteralPath $link)) { throw "missing $link" }
        $item = Get-Item -LiteralPath $link -Force
        if (-not ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) { throw "not junction $link" }
        $resolved = ([string]$item.Target).TrimEnd('\')
        $expected = $expectedSkills.TrimEnd('\')
        if ($resolved -ne $expected) { throw "wrong target $link -> $resolved (expected $expected)" }
    }
}
Check 'scheduled task readable' {
    $task = Get-ScheduledTask -TaskName $TaskName -ErrorAction Stop
    $info = Get-ScheduledTaskInfo -TaskName $TaskName -ErrorAction Stop
    if (-not $task.Actions) { throw 'scheduled task has no action' }
    if ($task.Actions.Arguments -notlike "*$expectedUpdater*") { throw "scheduled task does not invoke $expectedUpdater" }
    Write-Output ("  Task={0} State={1} LastResult={2} Next={3}" -f $task.TaskName, $task.State, $info.LastTaskResult, $info.NextRunTime)
}
Check 'registry configuration readable' {
    $key = Get-ItemProperty -Path 'HKCU:\Software\HeruAgentSkills' -ErrorAction Stop
    if ($key.InstallRoot -ne $RepoPath) { throw "InstallRoot mismatch: $($key.InstallRoot)" }
    if ($key.SkillsRoot -ne $expectedSkills) { throw "SkillsRoot mismatch: $($key.SkillsRoot)" }
    if ($key.Updater -ne $expectedUpdater) { throw "Updater mismatch: $($key.Updater)" }
}

if ($failures.Count) {
    Write-Output "AUDIT FAILED ($($failures.Count) check(s))"
    exit 1
}
Write-Output 'AUDIT PASSED (read-only; no updater invoked)'
exit 0
