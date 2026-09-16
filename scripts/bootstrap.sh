#!/bin/sh

# Find .vcpkg-root.
vcpkgRootDir=$(X= cd -- "$(dirname -- "$0")" && pwd -P)
while [ "$vcpkgRootDir" != "/" ] && ! [ -e "$vcpkgRootDir/.vcpkg-root" ]; do
    vcpkgRootDir="$(dirname "$vcpkgRootDir")"
done

# Parse arguments.
vcpkgDisableMetrics="OFF"
vcpkgUseSystem=false
vcpkgUseMuslC="OFF"
vcpkgSkipDependencyChecks="OFF"
for var in "$@"
do
    if [ "$var" = "-disableMetrics" -o "$var" = "--disableMetrics" ]; then
        vcpkgDisableMetrics="ON"
    elif [ "$var" = "-useSystemBinaries" -o "$var" = "--useSystemBinaries" ]; then
        echo "Warning: -useSystemBinaries no longer has any effect; ignored. Note that the VCPKG_USE_SYSTEM_BINARIES environment variable behavior is not changed."
    elif [ "$var" = "-allowAppleClang" -o "$var" = "--allowAppleClang" ]; then
        echo "Warning: -allowAppleClang no longer has any effect; ignored."
    elif [ "$var" = "-buildTests" ]; then
        echo "Warning: -buildTests no longer has any effect; ignored."
    elif [ "$var" = "-skipDependencyChecks" ]; then
        vcpkgSkipDependencyChecks="ON"
    elif [ "$var" = "-musl" ]; then
        vcpkgUseMuslC="ON"
    elif [ "$var" = "-help" -o "$var" = "--help" ]; then
        echo "Usage: ./bootstrap-vcpkg.sh [options]"
        echo
        echo "Options:"
        echo "    -help                 Display usage help"
        echo "    -disableMetrics       Mark this vcpkg root to disable metrics."
        echo "    -skipDependencyChecks Skip checks for vcpkg prerequisites. vcpkg may not run."
        echo "    -musl                 Use the musl binary rather than the glibc binary on Linux."
        exit 1
    else
        echo "Unknown argument $var. Use '-help' for help."
        exit 1
    fi
done

# Enable using this entry point on Windows from an msys2 or cygwin bash env. (e.g., git bash) by redirecting to the .bat file.
unixKernelName=$(uname -s | sed -E 's/(CYGWIN|MINGW|MSYS).*_NT.*/\1_NT/')
if [ "$unixKernelName" = CYGWIN_NT ] || [ "$unixKernelName" = MINGW_NT ] || [ "$unixKernelName" = MSYS_NT ]; then
    if [ "$vcpkgDisableMetrics" = "ON" ]; then
        args="-disableMetrics"
    else
        args=""
    fi

    vcpkgRootDir=$(cygpath -aw "$vcpkgRootDir")
    cmd "/C $vcpkgRootDir\\bootstrap-vcpkg.bat $args" || exit 1
    exit 0
fi

# Determine the downloads directory.
if [ -z ${VCPKG_DOWNLOADS+x} ]; then
    downloadsDir="$vcpkgRootDir/downloads"
else
    downloadsDir="$VCPKG_DOWNLOADS"
    if [ ! -d "$VCPKG_DOWNLOADS" ]; then
        echo "VCPKG_DOWNLOADS was set to '$VCPKG_DOWNLOADS', but that was not a directory."
        exit 1
    fi

fi

# Check for minimal prerequisites.
vcpkgCheckRepoTool()
{
    __tool=$1
    # Only perform dependency checks when they are not explicitly skipped.
    if [ "$vcpkgSkipDependencyChecks" = "OFF" ]; then
        if ! command -v "$__tool" >/dev/null 2>&1 ; then
            echo "Could not find $__tool. Please install it (and other dependencies) with:"
            echo "On Debian and Ubuntu derivatives:"
            echo "  sudo apt-get install curl zip unzip tar"
            echo "On recent Red Hat and Fedora derivatives:"
            echo "  sudo dnf install curl zip unzip tar"
            echo "On older Red Hat and Fedora derivatives:"
            echo "  sudo yum install curl zip unzip tar"
            echo "On SUSE Linux and derivatives:"
            echo "  sudo zypper install curl zip unzip tar"
            echo "On Arch Linux and derivatives:"
            echo "  sudo pacman -Syu base-devel git curl zip unzip tar cmake ninja"
            echo "On Alpine:"
            echo "  apk add build-base cmake ninja zip unzip curl git"
            echo "  (and export VCPKG_FORCE_SYSTEM_BINARIES=1)"
            echo "On Solaris and illumos distributions:"
            echo "  pkg install web/curl compress/zip compress/unzip"
            echo "On FreeBSD:"
            echo "  pkg install curl zip unzip tar"
            echo "On OpenBSD:"
            echo "  pkg_add curl zip unzip tar"
            exit 1
        fi
    fi
}

vcpkgCheckRepoTool curl
vcpkgCheckRepoTool zip
vcpkgCheckRepoTool unzip
vcpkgCheckRepoTool tar

UNAME="$(uname)"
ARCH="$(uname -m)"

if [ -e /etc/alpine-release ]; then
    vcpkgUseSystem="ON"
    vcpkgUseMuslC="ON"
fi

if [ "$UNAME" = "OpenBSD" ]; then
    vcpkgUseSystem="ON"
fi

if [ "$vcpkgUseSystem" = "ON" ]; then
    vcpkgCheckRepoTool cmake
    vcpkgCheckRepoTool ninja
    vcpkgCheckRepoTool git
fi

vcpkgCheckEqualFileHash()
{
    url=$1; filePath=$2; expectedHash=$3

    if command -v "sha512sum" >/dev/null 2>&1 ; then
        actualHash=$(sha512sum "$filePath")
    elif command -v "sha512" >/dev/null 2>&1 ; then
        # OpenBSD
        actualHash=$(sha512 -q "$filePath")
    else
        # [g]sha512sum is not available by default on osx
        # shasum is not available by default on Fedora
        actualHash=$(shasum -a 512 "$filePath")
    fi

    actualHash="${actualHash%% *}" # shasum returns [hash filename], so get the first word

    if ! [ "$expectedHash" = "$actualHash" ]; then
        echo ""
        echo "File does not have expected hash:"
        echo "              url: [ $url ]"
        echo "        File path: [ $downloadPath ]"
        echo "    Expected hash: [ $sha512 ]"
        echo "      Actual hash: [ $actualHash ]"
        exit 1
    fi
}

vcpkgDownloadFile()
{
    url=$1; downloadPath=$2; sha512=$3
    rm -rf "$downloadPath.part"

    # GitHub 链接优先使用镜像加速
    case "$url" in
        https://github.com/*)
            mirrorUrl="https://down.npee.cn?$url"
            echo "正在从镜像下载: $mirrorUrl"
            if curl -L "$mirrorUrl" --tlsv1.2 --create-dirs --retry 1 --output "$downloadPath.part" --silent --show-error --fail 2>/dev/null; then
                vcpkgCheckEqualFileHash "$url" "$downloadPath.part" "$sha512"
                chmod +x "$downloadPath.part"
                mv "$downloadPath.part" "$downloadPath"
                return
            fi
            echo "镜像下载失败，回退到原始地址。"
            rm -rf "$downloadPath.part"
            ;;
    esac

    curl -L $url --tlsv1.2 --create-dirs --retry 3 --output "$downloadPath.part" --silent --show-error --fail || exit 1

    vcpkgCheckEqualFileHash $url "$downloadPath.part" $sha512
    chmod +x "$downloadPath.part"
    mv "$downloadPath.part" "$downloadPath"
}

vcpkgExtractArchive()
{
    archive=$1; toPath=$2
    rm -rf "$toPath" "$toPath.partial"
    case "$archive" in
        *.tar.gz)
            mkdir -p "$toPath.partial"
            $(cd "$toPath.partial" && tar xzf "$archive")
            ;;
        *.zip)
            unzip -qd "$toPath.partial" "$archive"
            ;;
    esac
    mv "$toPath.partial" "$toPath"
}

# Determine what we are going to do to bootstrap:
# MacOS -> Download vcpkg-macos
# Linux
#   useMuslC -> download vcpkg-muslc
#   amd64 -> download vcpkg-glibc
#   arm64 -> download vcpkg-glibc-arm64
# Otherwise
#   Download and build from source

# Read the vcpkg-tool config file to determine what release to download
. "$vcpkgRootDir/scripts/vcpkg-tool-metadata.txt"

vcpkgDownloadTool="ON"
if [ "$UNAME" = "Darwin" ]; then
    echo "Downloading vcpkg-macos..."
    vcpkgToolReleaseSha=$VCPKG_MACOS_SHA
    vcpkgToolName="vcpkg-macos"
elif [ "$UNAME" = "Linux" ] && [ "$vcpkgUseMuslC" = "ON" ] && [ "$ARCH" = "x86_64" ]; then
    echo "Downloading vcpkg-muslc..."
    vcpkgToolReleaseSha=$VCPKG_MUSLC_SHA
    vcpkgToolName="vcpkg-muslc"
elif [ "$UNAME" = "Linux" ] && [ "$ARCH" = "x86_64" ]; then
    echo "Downloading vcpkg-glibc..."
    vcpkgToolReleaseSha=$VCPKG_GLIBC_SHA
    vcpkgToolName="vcpkg-glibc"
elif [ "$UNAME" = "Linux" ] && [ "$vcpkgUseMuslC" = "OFF" ] && { [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; }; then
    echo "Downloading vcpkg-arm64-glibc..."
    vcpkgToolReleaseSha=$VCPKG_GLIBC_ARM64_SHA
    vcpkgToolName="vcpkg-glibc-arm64"
else
    echo "Unable to determine a binary release of vcpkg; attempting to build from source."
    vcpkgDownloadTool="OFF"
    vcpkgToolReleaseSha=$VCPKG_TOOL_SOURCE_SHA
fi

# Do the download or build.
if [ "$vcpkgDownloadTool" = "ON" ]; then
    vcpkgDownloadFile "https://github.com/microsoft/vcpkg-tool/releases/download/$VCPKG_TOOL_RELEASE_TAG/$vcpkgToolName" "$vcpkgRootDir/vcpkg" $vcpkgToolReleaseSha
else
    vcpkgToolReleaseArchive="$VCPKG_TOOL_RELEASE_TAG.zip"
    vcpkgToolUrl="https://github.com/microsoft/vcpkg-tool/archive/$vcpkgToolReleaseArchive"
    baseBuildDir="$vcpkgRootDir/buildtrees/_vcpkg"
    buildDir="$baseBuildDir/build"
    archivePath="$downloadsDir/$vcpkgToolReleaseArchive"
    srcBaseDir="$baseBuildDir/src"
    srcDir="$srcBaseDir/vcpkg-tool-$VCPKG_TOOL_RELEASE_TAG"

    if [ -e "$archivePath" ]; then
        vcpkgCheckEqualFileHash "$vcpkgToolUrl" "$archivePath" "$vcpkgToolReleaseSha"
    else
        echo "Downloading vcpkg tool sources"
        vcpkgDownloadFile "$vcpkgToolUrl" "$archivePath" "$vcpkgToolReleaseSha"
    fi

    echo "Building vcpkg-tool..."
    rm -rf "$baseBuildDir"
    mkdir -p "$buildDir"
    vcpkgExtractArchive "$archivePath" "$srcBaseDir"
    cmakeConfigOptions="-DCMAKE_BUILD_TYPE=Release -G 'Ninja' -DVCPKG_DEVELOPMENT_WARNINGS=OFF"

    if [ "${VCPKG_MAX_CONCURRENCY}" != "" ] ; then
        cmakeConfigOptions=" $cmakeConfigOptions '-DCMAKE_JOB_POOL_COMPILE:STRING=compile' '-DCMAKE_JOB_POOL_LINK:STRING=link' '-DCMAKE_JOB_POOLS:STRING=compile=$VCPKG_MAX_CONCURRENCY;link=$VCPKG_MAX_CONCURRENCY' "
    fi

    (cd "$buildDir" && eval cmake "$srcDir" $cmakeConfigOptions) || exit 1
    (cd "$buildDir" && cmake --build .) || exit 1

    rm -rf "$vcpkgRootDir/vcpkg"
    cp "$buildDir/vcpkg" "$vcpkgRootDir/"
fi

"$vcpkgRootDir/vcpkg" version --disable-metrics

# 应用遥测禁用标记文件
if [ "$vcpkgDisableMetrics" = "ON" ]; then
    touch "$vcpkgRootDir/vcpkg.disable-metrics"
elif ! [ -f "$vcpkgRootDir/vcpkg.disable-metrics" ]; then
    # 如果用户已选择退出遥测，则保持退出状态不变
    cat <<EOF
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
EOF
fi
