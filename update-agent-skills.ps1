# Comprehensive Auto-Sync Script for 9 Repositories (Skills, AI Frameworks, smolagents, Academic Templates)
$repos = @(
    @{ Name = "AddyOsmani-AgentSkills"; Path = "D:\agent-skills" },
    @{ Name = "NVIDIA-MLSkills"; Path = "D:\nvidia-skills" },
    @{ Name = "LangGraph-Framework"; Path = "D:\ai-frameworks\langgraph" },
    @{ Name = "PydanticAI-Framework"; Path = "D:\ai-frameworks\pydantic-ai" },
    @{ Name = "ClaudeContext-VectorSearch"; Path = "D:\ai-frameworks\claude-context" },
    @{ Name = "ECC-AgentMemoryHarness"; Path = "D:\ai-frameworks\ECC" },
    @{ Name = "HuggingFace-Smolagents"; Path = "D:\ai-frameworks\smolagents" },
    @{ Name = "Academic-Paper-Templates"; Path = "D:\ai-frameworks\academic-paper-templates" },
    @{ Name = "Elegant-Paper-LaTeX"; Path = "D:\ai-frameworks\elegant-paper" }
)
$logFile = "D:\agent-skills\sync.log"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

foreach ($repo in $repos) {
    $repoName = $repo.Name
    $repoPath = $repo.Path
    
    if (Test-Path $repoPath) {
        try {
            Set-Location -Path $repoPath
            git fetch origin --quiet 2>&1 | Out-Null
            
            $defaultBranch = git rev-parse --abbrev-ref origin/HEAD 2>$null
            if (-not $defaultBranch) { $defaultBranch = "origin/main" }
            
            $localCommit = git rev-parse HEAD
            $remoteCommit = git rev-parse $defaultBranch 2>$null
            
            if ($remoteCommit -and ($localCommit -ne $remoteCommit)) {
                $pullOutput = git pull --recurse-submodules 2>&1
                $msg = "[$timestamp] [$repoName] [UPDATED] Updated to $remoteCommit.`n$pullOutput"
            } else {
                $msg = "[$timestamp] [$repoName] [OK] Up to date ($localCommit)."
            }
        } catch {
            $msg = "[$timestamp] [$repoName] [ERROR] Failed to update: $($_.Exception.Message)"
        }
        Add-Content -Path $logFile -Value $msg
    }
}
