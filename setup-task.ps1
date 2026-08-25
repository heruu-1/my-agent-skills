[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$TaskName = 'AutoUpdateAgentSkills',
    [string]$ScriptPath = ''
)

$ErrorActionPreference = 'Stop'
if (-not $ScriptPath) { $ScriptPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'update-agent-skills.ps1' }
if (-not (Test-Path -LiteralPath $ScriptPath -PathType Leaf)) { throw "Updater not found: $ScriptPath" }

$powershell = (Get-Command powershell.exe -ErrorAction Stop).Source
$argument = "-NoProfile -NonInteractive -WindowStyle Hidden -File `"$ScriptPath`""
$action = New-ScheduledTaskAction -Execute $powershell -Argument $argument
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At 9am
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

if ($PSCmdlet.ShouldProcess($TaskName, 'Register or update the user-level scheduled task')) {
    Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings -Description 'Fail-closed weekly update for agent skills' -Force | Out-Null
    $task = Get-ScheduledTask -TaskName $TaskName -ErrorAction Stop
    if ($task.Actions[0].Execute -notlike '*powershell.exe') { throw 'Scheduled task action verification failed.' }
    Write-Output "SUCCESS: $TaskName registered for the current user."
}
