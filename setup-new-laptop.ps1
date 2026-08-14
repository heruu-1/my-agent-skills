# ==============================================================================
# ONE-CLICK AGENT SKILLS & FRAMEWORKS RESTORATION SCRIPT FOR NEW LAPTOP / PC
# ==============================================================================
Write-Output "==================================================="
Write-Output "   SETTING UP AGENT SKILLS ON NEW COMPUTER         "
Write-Output "==================================================="

$targetDrive = "D:"
if (-not (Test-Path "D:\")) {
    Write-Output "Drive D: not found, using C:\agent-skills instead."
    $targetDrive = "C:"
}

$agentSkillsDir = "$targetDrive\agent-skills"
$nvidiaDir = "$targetDrive\nvidia-skills"
$aiFrameworksDir = "$targetDrive\ai-frameworks"
$homeDir = [Environment]::GetFolderPath("UserProfile")

# 1. Install Astral uv
Write-Output "`n[1] Installing Astral uv package manager..."
powershell -ExecutionPolicy ByPass -Command "irm https://astral.sh/uv/install.ps1 | iex"

# 2. Clone / Restore Repositories
Write-Output "`n[2] Cloning Core Repositories..."
if (-not (Test-Path $agentSkillsDir)) {
    git clone --recurse-submodules -j8 https://github.com/addyosmani/agent-skills.git $agentSkillsDir
}
if (-not (Test-Path $nvidiaDir)) {
    git clone --depth 1 https://github.com/NVIDIA/skills.git $nvidiaDir
}

New-Item -ItemType Directory -Force -Path $aiFrameworksDir | Out-Null
$frameworks = @(
    @{ Name = "langgraph"; Url = "https://github.com/langchain-ai/langgraph.git" },
    @{ Name = "pydantic-ai"; Url = "https://github.com/pydantic/pydantic-ai.git" },
    @{ Name = "claude-context"; Url = "https://github.com/zilliztech/claude-context.git" },
    @{ Name = "ECC"; Url = "https://github.com/affaan-m/ECC.git" },
    @{ Name = "smolagents"; Url = "https://github.com/huggingface/smolagents.git" },
    @{ Name = "academic-paper-templates"; Url = "https://github.com/zardus/paper-templates.git" },
    @{ Name = "elegant-paper"; Url = "https://github.com/ElegantLaTeX/ElegantPaper.git" }
)

foreach ($fw in $frameworks) {
    $dest = "$aiFrameworksDir\$($fw.Name)"
    if (-not (Test-Path $dest)) {
        Write-Output " - Cloning $($fw.Name)..."
        git clone --depth 1 $fw.Url $dest
    }
}

# 3. Setup Universal Agent Compatibility
Write-Output "`n[3] Linking to All AI Agents (Gemini, Claude, Cursor, Codex, etc.)..."
powershell -ExecutionPolicy Bypass -File "$agentSkillsDir\setup-universal-agents.ps1"

# 4. Setup Windows Task Scheduler (Weekly Auto-Sync on Monday 09:00 AM)
Write-Output "`n[4] Registering Weekly Auto-Sync in Windows Task Scheduler..."
powershell -ExecutionPolicy Bypass -File "$agentSkillsDir\setup-task.ps1"

Write-Output "`n==================================================="
Write-Output "   NEW COMPUTER SETUP COMPLETED SUCCESSFULLY!      "
Write-Output "==================================================="
