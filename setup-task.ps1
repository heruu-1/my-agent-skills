$taskName = "AutoUpdateAgentSkills"
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File ""D:\agent-skills\update-agent-skills.ps1"""
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At 9am
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

try {
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Description "Auto sync Addy Osmani Agent Skills (Weekly on Monday)" -Force
    Write-Output "SUCCESS: Task '$taskName' successfully updated in Windows Task Scheduler (Weekly on Monday at 09:00)."
} catch {
    Write-Output "ERROR: Task update failed ($($_.Exception.Message))."
}
