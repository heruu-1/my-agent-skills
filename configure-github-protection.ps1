[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$Repository = 'heruu-1/my-agent-skills',
    [string]$Branch = 'main'
)

$ErrorActionPreference = 'Stop'
if (-not (Get-Command gh.exe -ErrorAction SilentlyContinue)) { throw 'GitHub CLI (gh.exe) is required.' }
if ($Repository -notmatch '^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$') { throw "Invalid GitHub repository: $Repository" }
if ($Branch -notmatch '^[A-Za-z0-9._/-]+$') { throw "Invalid branch: $Branch" }

$payload = [ordered]@{
    required_status_checks = [ordered]@{
        strict = $true
        contexts = @(
            'Validate Skills, Commands, Tests, and Routing',
            'Validate Windows automation'
        )
    }
    enforce_admins = $true
    required_pull_request_reviews = [ordered]@{
        dismiss_stale_reviews = $true
        require_code_owner_reviews = $false
        required_approving_review_count = 1
        require_last_push_approval = $false
    }
    restrictions = $null
    required_linear_history = $true
    allow_force_pushes = $false
    allow_deletions = $false
    block_creations = $false
    required_conversation_resolution = $true
    lock_branch = $false
    allow_fork_syncing = $true
}

$endpoint = "repos/$Repository/branches/$Branch/protection"
if (-not $PSCmdlet.ShouldProcess("https://github.com/$Repository/tree/$Branch", 'Enable branch protection')) {
    Write-Output "WHATIF: would PUT branch protection to $endpoint"
    exit 0
}

& gh.exe auth status 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'GitHub CLI is not authenticated. Run `gh auth login` and retry.' }

$tempFile = Join-Path ([IO.Path]::GetTempPath()) ("heru-branch-protection-" + [guid]::NewGuid().ToString('N') + '.json')
try {
    $payload | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $tempFile -Encoding UTF8
    & gh.exe api --method PUT $endpoint --input $tempFile
    if ($LASTEXITCODE -ne 0) { throw "GitHub branch-protection request failed with exit code $LASTEXITCODE" }
    Write-Output "BRANCH PROTECTION ENABLED: $Repository/$Branch"
} finally {
    if (Test-Path -LiteralPath $tempFile) { Remove-Item -LiteralPath $tempFile -Force }
}
