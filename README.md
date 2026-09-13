[中文](README.md) | [English](README_EN.md)

# vcpkg-CN：vcpkg 中文加速版

基于 Microsoft vcpkg 的中文优化版本，针对国内开发者做了以下加速和优化：

- GitHub 下载全量加速（通过 `down.npee.cn` 镜像）
- 解决中文用户名导致 MSVC 编译失败的问题
- 附带常用库的预编译缓存（raylib、glfw3 等）

## 快速开始

### 1. 环境要求

- Visual Studio 2022/2026（含 C++ 桌面开发工作负载）
- CMake 3.20+

### 2. 设置临时目录（重要）

Windows 用户名包含中文时，MSVC 编译器会因 TEMP 路径含非 ASCII 字符而报错（`D8050`）。
请以管理员身份运行 PowerShell，执行以下命令：

```powershell
New-Item -ItemType Directory -Path "C:\Temp" -Force
[Environment]::SetEnvironmentVariable("TEMP", "C:\Temp", "User")
[Environment]::SetEnvironmentVariable("TMP", "C:\Temp", "User")
```

设置后**重启终端**生效。

### 3. 安装包

```powershell
cd <vcpkg-CN 目录>
.\vcpkg.exe install raylib --triplet x64-windows
```

### 4. 在 CMake 项目中使用

```bash
cmake -DCMAKE_TOOLCHAIN_FILE=<vcpkg-CN 目录>/scripts/buildsystems/vcpkg.cmake ..
```

## 已做的优化

### GitHub 下载加速

修改了 `scripts/cmake/vcpkg_download_distfile.cmake`，所有 `github.com` 的下载请求自动通过 `https://down.npee.cn` 镜像加速：

```cmake
foreach(url IN LISTS arg_URLS)
    if(url MATCHES "^https://github\.com/" AND NOT url MATCHES "^https://down\.npee\.cn")
        vcpkg_list(APPEND params "--url=https://down.npee.cn?${url}")
    else()
        vcpkg_list(APPEND params "--url=${url}")
    endif()
endforeach()
```

覆盖范围：
- `vcpkg_from_github`（archive/tarball 下载）
- 直接 `vcpkg_download_distfile` 调用
- GitHub releases 下载

### 下载优先级

1. `down.npee.cn` 镜像（GitHub 源加速）
2. 原始 GitHub URL（兜底）

## 与上游 vcpkg 的区别

| 项目 | 上游 vcpkg | vcpkg-CN |
|------|-----------|----------|
| GitHub 下载 | 直连 github.com | 通过 down.npee.cn 镜像加速 |
| Asset cache | 需手动配置 | 预配置阿里云镜像 |
| TEMP 路径问题 | 不处理 | 文档说明并提供解决方案 |
| 预编译包 | 无 | 附带常用库缓存 |

## 使用示例

安装包：
```powershell
.\vcpkg.exe install fmt --triplet x64-windows
```

查看已安装的包：
```powershell
.\vcpkg.exe list
```

搜索可用的包：
```powershell
.\vcpkg.exe search sqlite
```

## 许可证

MIT License。各端口提供的库遵循其原始作者的许可条款。

## 相关链接

- [上游 vcpkg 仓库](https://github.com/microsoft/vcpkg)
- [vcpkg 官方文档](https://learn.microsoft.com/vcpkg/)
- [vcpkg-tool 源码](https://github.com/microsoft/vcpkg-tool)

## 贡献

欢迎提交 Issue 和 PR：
- [提交 Issue](https://github.com/cc-Infiltration/vcpkg-CN/issues/new/choose)
- [提交 PR](https://github.com/cc-Infiltration/vcpkg-CN/pulls)
