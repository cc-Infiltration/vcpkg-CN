@echo off
setlocal enabledelayedexpansion

rem =========================
rem update-sync.bat
rem 用法:
rem   update-sync.bat [target-branch] [upstream-remote] [use-merge]
rem 示例:
rem   update-sync.bat            (在当前分支上用 upstream/relevant-branch rebase)
rem   update-sync.bat main upstream 0
rem   update-sync.bat develop origin 1   (用 merge 而非 rebase)
rem =========================

rem Defaults
set TARGET_BRANCH=
set UPSTREAM_REMOTE=upstream
set USE_MERGE=0

if not "%~1"=="" set TARGET_BRANCH=%~1
if not "%~2"=="" set UPSTREAM_REMOTE=%~2
if not "%~3"=="" set USE_MERGE=%~3

rem Check git exists
git --version >nul 2>&1
if errorlevel 1 (
  echo ERROR: git 未检测到，请先安装 git 并确保在 PATH 中.
  exit /b 1
)

rem get current branch
for /f "usebackq delims=" %%b in (`git rev-parse --abbrev-ref HEAD`) do set CURRENT_BRANCH=%%b
if "%TARGET_BRANCH%"=="" set TARGET_BRANCH=%CURRENT_BRANCH%

rem timestamp
for /f "usebackq delims=" %%t in (`powershell -NoProfile -Command "Get-Date -Format yyyyMMdd-HHmmss"`) do set TS=%%t

echo.
echo ==== 同步脚本开始 ====
echo 当前分支: %CURRENT_BRANCH%
echo 目标分支: %TARGET_BRANCH%
echo 上游 remote: %UPSTREAM_REMOTE%
if "%USE_MERGE%"=="1" (
  echo 同步方式: merge (保守，不改写历史)
) else (
  echo 同步方式: rebase (推荐，保留历史整洁，但会改写本地分支历史)
)
echo 备份分支将命名为: backup/%TARGET_BRANCH%-%TS%
echo.

rem check if remote exists
git remote get-url %UPSTREAM_REMOTE% >nul 2>&1
if errorlevel 1 (
  echo WARNING: remote "%UPSTREAM_REMOTE%" 未找到.
  echo 请先添加上游 remote，例如:
  echo   git remote add %UPSTREAM_REMOTE% https://github.com/ORIGINAL_OWNER/REPO.git
  exit /b 2
)

rem detect uncommitted changes
set HAS_CHANGES=
for /f "usebackq delims=" %%s in (`git status --porcelain`) do set HAS_CHANGES=1

set STASHED=0
if defined HAS_CHANGES (
  echo 未提交改动/未跟踪文件检测到，正在自动 stash (带 untracked)...
  git stash push -u -m "auto-stash before sync %TS%" >nul 2>&1
  if errorlevel 1 (
    echo ERROR: stash 失败，请手动处理未提交改动后重试.
    exit /b 3
  )
  set STASHED=1
  echo 已 stash，稍后会尝试 pop.
)

rem create backup branch (from current HEAD)
git branch backup/%TARGET_BRANCH%-%TS% >nul 2>&1
if errorlevel 1 (
  echo ERROR: 无法创建备份分支 backup/%TARGET_BRANCH%-%TS%.
  if "%STASHED%"=="1" (
    echo 正在还原之前的 stash...
    git stash pop --index >nul 2>&1
  )
  exit /b 4
)
echo 备份分支 backup/%TARGET_BRANCH%-%TS% 已创建.

rem fetch upstream
echo 从 %UPSTREAM_REMOTE% 拉取最新...
git fetch %UPSTREAM_REMOTE%
if errorlevel 1 (
  echo ERROR: fetch 失败，请检查网络与 remote 配置.
  if "%STASHED%"=="1" (
    echo 正在还原 stash...
    git stash pop --index >nul 2>&1
  )
  exit /b 5
)

rem checkout target branch
echo 切换到目标分支 %TARGET_BRANCH% ...
git checkout %TARGET_BRANCH%
if errorlevel 1 (
  echo ERROR: 切换分支失败，请确认分支存在.
  if "%STASHED%"=="1" (
    echo 正在还原 stash...
    git stash pop --index >nul 2>&1
  )
  exit /b 6
)

rem perform rebase or merge
if "%USE_MERGE%"=="1" (
  echo 正在合并 %UPSTREAM_REMOTE%/%TARGET_BRANCH% -> %TARGET_BRANCH% ...
  git merge %UPSTREAM_REMOTE%/%TARGET_BRANCH%
  if errorlevel 1 (
    echo MERGE 停止，可能存在冲突。
    echo 请输入: git status 以查看冲突文件，手动解决冲突后运行: git commit (如需), 然后:
    echo   git push origin %TARGET_BRANCH%
    echo 脚本结束，冲突需人工解决。
    exit /b 7
  )
) else (
  echo 正在 rebase 到 %UPSTREAM_REMOTE%/%TARGET_BRANCH% ...
  git rebase %UPSTREAM_REMOTE%/%TARGET_BRANCH%
  if errorlevel 1 (
    echo REBASE 停止，可能存在冲突。
    echo 请手动解决冲突后运行:
    echo   git add <conflicted-files>
    echo   git rebase --continue
    echo 或放弃变基并回到原状态:
    echo   git rebase --abort
    echo 完成变基后请手动执行:
    echo   git push --force-with-lease origin %TARGET_BRANCH%
    if "%STASHED%"=="1" (
      echo 注意：你的改动已被 stash，变基完成并推送后请运行 git stash pop 以恢复未提交改动（或手动恢复）。
    )
    exit /b 8
  )
)

rem push result
echo 变基/合并成功，正在将结果推送到 origin/%TARGET_BRANCH% (使用 --force-with-lease 当 rebase 时)...
if "%USE_MERGE%"=="1" (
  git push origin %TARGET_BRANCH%
) else (
  git push --force-with-lease origin %TARGET_BRANCH%
)
if errorlevel 1 (
  echo WARNING: push 失败或被拒绝，请检查权限或远程状态并手动推送.
  if "%STASHED%"=="1" (
    echo 正在尝试还原 stash...
    git stash pop --index >nul 2>&1
  )
  exit /b 9
)

rem restore stash if any
if "%STASHED%"=="1" (
  echo 正在尝试还原之前的 stash...
  git stash pop --index
  if errorlevel 1 (
    echo NOTICE: stash pop 失败，可能存在冲突。请运行 'git stash list' 与 'git stash apply' 手动检查。
  ) else (
    echo stash 已还原.
  )
)

echo.
echo ==== 同步完成 ====
echo 备份分支: backup/%TARGET_BRANCH%-%TS%
echo 如果出现冲突，请按脚本提示手动解决并完成 rebase/merge，然后手动推送。
endlocal
exit /b 0
