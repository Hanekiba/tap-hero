# ============================================================
#  自动部署到 GitHub Pages — https://hanekiba.github.io/tap-hero/
#  用法：.\site\deploy.ps1
# ============================================================

$ErrorActionPreference = "Continue"

# 自动找 git
$GIT = $null
$gitCmd = Get-Command git -ErrorAction SilentlyContinue
if ($gitCmd) { $GIT = $gitCmd.Source }
if (-not $GIT) {
    $portable = "$env:USERPROFILE\.workbuddy\vendor\PortableGit\mingw64\bin\git.exe"
    if (Test-Path $portable) { $GIT = $portable }
}
if (-not $GIT) {
    Write-Host "can't find git" -ForegroundColor Red
    exit 1
}

$REPO = "https://github.com/Hanekiba/tap-hero.git"
$BR   = "main"
$DIR  = Split-Path -Parent $PSCommandPath
Set-Location $DIR

Write-Host "deploy -> $REPO : $BR"

# init if needed
if (-not (Test-Path ".git")) {
    Write-Host "git init..."
    & $GIT init
    & $GIT branch -M $BR
    & $GIT remote add origin $REPO
}

# 确保 git user 已设置（否则 commit 会报错）
$userName = & $GIT config user.name
if (-not $userName) { & $GIT config user.name "Hanekiba" }
$userEmail = & $GIT config user.email
if (-not $userEmail) { & $GIT config user.email "hanekiba@users.noreply.github.com" }

# fetch remote
Write-Host "fetch..."
$env:GIT_TERMINAL_PROMPT = "0"
$out = & $GIT ls-remote origin $BR 2>&1 | Out-String
if ($out -match $BR) {
    Write-Host "  remote exists, pulling..."
    & $GIT fetch origin $BR
    & $GIT reset --soft "origin/$BR"
}
else {
    Write-Host "  first push"
}

# add + commit
& $GIT add -A
& $GIT diff --cached --quiet
if ($LASTEXITCODE -eq 0) {
    Write-Host "no changes, up to date."
    exit 0
}

$msg = "deploy: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
& $GIT commit -m $msg

Write-Host "pushing..."
& $GIT push -u origin $BR

Write-Host ""
Write-Host "done! https://hanekiba.github.io/tap-hero/" -ForegroundColor Green
