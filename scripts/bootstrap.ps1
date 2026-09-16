[CmdletBinding()]
param(
    $badParam,
    [Parameter(Mandatory=$False)][switch]$win64 = $false,
    [Parameter(Mandatory=$False)][string]$withVSPath = "",
    [Parameter(Mandatory=$False)][string]$withWinSDK = "",
    [Parameter(Mandatory=$False)][switch]$disableMetrics = $false
)
Set-StrictMode -Version Latest
# 强制使用命名参数（兼容 PowerShell 2）
if ($badParam)
{
    if ($disableMetrics -and $badParam -eq "1")
    {
        Write-Warning "'disableMetrics 1' 已弃用，请改用 'disableMetrics'（不带 '1'）。"
    }
    else
    {
        throw "仅允许使用命名参数。"
    }
}

if ($win64)
{
    Write-Warning "-win64 已无效果，忽略。"
}

if (-Not [string]::IsNullOrWhiteSpace($withVSPath))
{
    Write-Warning "-withVSPath 已无效果，忽略。"
}

if (-Not [string]::IsNullOrWhiteSpace($withWinSDK))
{
    Write-Warning "-withWinSDK 已无效果，忽略。"
}

$scriptsDir = split-path -parent $script:MyInvocation.MyCommand.Definition
$vcpkgRootDir = $scriptsDir
while (!($vcpkgRootDir -eq "") -and !(Test-Path "$vcpkgRootDir\.vcpkg-root"))
{
    Write-Verbose "正在检查 $vcpkgRootDir 是否存在 .vcpkg-root"
    $vcpkgRootDir = Split-path $vcpkgRootDir -Parent
}

Write-Verbose "已在 $vcpkgRootDir 找到 .vcpkg-root"

# 读取 vcpkg-tool 配置文件以确定要下载的版本
$Config = ConvertFrom-StringData (Get-Content "$PSScriptRoot\vcpkg-tool-metadata.txt" -Raw)
$versionDate = $Config.VCPKG_TOOL_RELEASE_TAG

# 判断 CPU 架构，选择对应的二进制文件
if ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64' -or $env:PROCESSOR_IDENTIFIER -match "ARMv[8,9] \(64-bit\)") {
    $vcpkgToolName = "vcpkg-arm64.exe"
} else {
    $vcpkgToolName = "vcpkg.exe"
}

$originalUrl = "https://github.com/microsoft/vcpkg-tool/releases/download/$versionDate/$vcpkgToolName"
$mirrorUrl = "https://down.npee.cn?$originalUrl"
$downloaded = $false

# 先尝试通过镜像加速下载
try {
    # 设置编码为 UTF-8，兼容 PowerShell 5（控制台默认 GBK）和 PowerShell 7（默认 UTF-8）
    $previousEncoding = [Console]::OutputEncoding
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    Write-Host "正在从镜像下载 vcpkg.exe..."
    Invoke-WebRequest -Uri $mirrorUrl -OutFile "$vcpkgRootDir\vcpkg.exe" -UseBasicParsing -ErrorAction Stop
    $downloaded = $true
    Write-Host "镜像下载成功。"
} catch {
    Write-Warning "镜像下载失败，回退到原始下载方式。"
} finally {
    if ($previousEncoding) {
        [Console]::OutputEncoding = $previousEncoding
    }
}

# 回退到原始 tls12-download 工具下载
if (-not $downloaded) {
    if ($vcpkgToolName -eq "vcpkg-arm64.exe") {
        & "$scriptsDir/tls12-download-arm64.exe" github.com "/microsoft/vcpkg-tool/releases/download/$versionDate/vcpkg-arm64.exe" "$vcpkgRootDir\vcpkg.exe"
    } else {
        & "$scriptsDir/tls12-download.exe" github.com "/microsoft/vcpkg-tool/releases/download/$versionDate/vcpkg.exe" "$vcpkgRootDir\vcpkg.exe"
    }
}

Write-Host ""

# 检查下载是否成功（$downloaded 为 true 时跳过 $LASTEXITCODE 检查，避免未定义变量报错）
if (-not $downloaded -and $LASTEXITCODE -ne 0)
{
    Write-Error "下载 vcpkg.exe 失败。请检查网络连接，或手动从 https://github.com/microsoft/vcpkg-tool 下载。"
    throw
}

& "$vcpkgRootDir\vcpkg.exe" version --disable-metrics

if ($disableMetrics)
{
    Set-Content -Value "" -Path "$vcpkgRootDir\vcpkg.disable-metrics" -Force
}
elseif (-Not (Test-Path "$vcpkgRootDir\vcpkg.disable-metrics"))
{
    # 如果用户已选择退出遥测，则保持退出状态不变
    Write-Host @"
遥测
----
vcpkg 会收集使用数据以帮助改善用户体验。
Microsoft 收集的数据是匿名的。
你可以通过以下方式退出遥测：
  - 重新运行 bootstrap-vcpkg 脚本并添加 -disableMetrics 参数
  - 在命令行中向 vcpkg 传递 --disable-metrics 参数
  - 设置 VCPKG_DISABLE_METRICS 环境变量

了解更多：https://learn.microsoft.com/vcpkg/about/privacy
Microsoft 隐私声明：https://go.microsoft.com/fwlink/?LinkId=521839
"@
}
