Write-Output "Pushing D:\agent-skills to https://github.com/heruu-1/my-agent-skills.git..."
git -C "D:\agent-skills" push -u mybackup main
if ($LASTEXITCODE -eq 0) {
    Write-Output "`n[SUCCESS] All 38 Skills, Subagents, and Frameworks successfully backed up to your GitHub!"
} else {
    Write-Output "`n[NOTE] If repository is not created yet, please create it at: https://github.com/new?name=my-agent-skills"
}
