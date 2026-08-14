$homeDir = "C:\Users\ACER"
$agentSkillsDir = "D:\agent-skills"
$skillsDir = "D:\agent-skills\skills"
$nvidiaDir = "D:\nvidia-skills"

Write-Output "==================================================="
Write-Output "    CONFIGURING UNIVERSAL AGENT COMPATIBILITY      "
Write-Output "==================================================="

# Helper function to create junction safely
function Create-JunctionIfNotExist($linkPath, $targetPath) {
    if (-not (Test-Path $linkPath)) {
        $parent = Split-Path -Parent $linkPath
        if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
        cmd /c mklink /J "$linkPath" "$targetPath" 2>&1 | Out-Null
        Write-Output " [CREATED] $linkPath -> $targetPath"
    } else {
        Write-Output " [EXISTS]  $linkPath"
    }
}

# 1. Antigravity / Google Gemini Code Assist
Write-Output "`n[1] Antigravity / Gemini Code Assist:"
Create-JunctionIfNotExist "$homeDir\.gemini\config\plugins\agent-skills" $agentSkillsDir
Create-JunctionIfNotExist "$homeDir\.gemini\config\plugins\nvidia-skills" $nvidiaDir

# 2. Claude Code / Anthropic
Write-Output "`n[2] Claude Code:"
Create-JunctionIfNotExist "$homeDir\.claude\skills" $skillsDir
Create-JunctionIfNotExist "$homeDir\.claude\plugins\agent-skills" $agentSkillsDir
Create-JunctionIfNotExist "$homeDir\.claude\plugins\nvidia-skills" $nvidiaDir

# 3. Universal .agents Directory (OpenCode, Codex, Terminal Agents, CLI Agents)
Write-Output "`n[3] Universal .agents Standard:"
Create-JunctionIfNotExist "$homeDir\.agents\skills" $skillsDir
Create-JunctionIfNotExist "$homeDir\.agents\plugins\agent-skills" $agentSkillsDir
Create-JunctionIfNotExist "$homeDir\.agents\plugins\nvidia-skills" $nvidiaDir
Create-JunctionIfNotExist "$homeDir\.agents\references" "$agentSkillsDir\references"

# 4. Cursor IDE
Write-Output "`n[4] Cursor IDE:"
Create-JunctionIfNotExist "$homeDir\.cursor\skills" $skillsDir
Create-JunctionIfNotExist "$homeDir\.cursor\rules" "$agentSkillsDir\references"

# 5. OpenCode & Codex Plugin Paths
Write-Output "`n[5] OpenCode & Codex Ecosystem:"
Create-JunctionIfNotExist "$homeDir\.opencode\skills" $skillsDir
Create-JunctionIfNotExist "$homeDir\.codex\skills" $skillsDir

# 6. Cline & Roo Code & Continue (VS Code Extensions)
Write-Output "`n[6] Cline, Roo Code & Continue Extension Paths:"
Create-JunctionIfNotExist "$homeDir\.continue\skills" $skillsDir
Create-JunctionIfNotExist "$homeDir\.cline\skills" $skillsDir
Create-JunctionIfNotExist "$homeDir\.roo\skills" $skillsDir

Write-Output "`n==================================================="
Write-Output "  ALL AGENTS SUCCESSFULLY CONFIGURED AND LINKED!   "
Write-Output "==================================================="
