Package: glfw3:x64-windows@3.4#1

**Host Environment**

- Host: x64-windows
- Compiler: MSVC 19.51.36257.0
- CMake Version: 4.4.0
-    vcpkg-tool version: 2026-07-27-98d7cb0cf1f4686a3e43aa5672b6230c1d56bce8
    vcpkg-scripts version: unknown

**To Reproduce**

`vcpkg install glfw3`

**Failure logs**

```
Trying to download glfw-glfw-3.4.tar.gz using asset cache https://mirrors.aliyun.com/vcpkg/assets/39ad7a4521267fbebc35d2ff0c389a56236ead5fa4bdff33db113bd302f70f5f2869ff4e6db1979512e1542813292dff5a482e94dfce231750f0746c301ae9ed
Asset cache miss; trying authoritative source https://down.npee.cn?https://github.com/glfw/glfw/archive/3.4.tar.gz
Successfully downloaded glfw-glfw-3.4.tar.gz
-- Extracting source D:/vcpkg-2026/downloads/glfw-glfw-3.4.tar.gz
-- Using source at D:/vcpkg-2026/buildtrees/glfw3/src/3.4-2448ff4533.clean
-- Configuring x64-windows
CMake Error at scripts/cmake/vcpkg_execute_required_process.cmake:127 (message):
    Command failed: D:\\software\\VisualStdio26\\Common7\\IDE\\CommonExtensions\\Microsoft\\CMake\\Ninja\\ninja.exe -v
    Working Directory: D:/vcpkg-2026/buildtrees/glfw3/x64-windows-rel/vcpkg-parallel-configure
    Error code: 1
    See logs for more information:
      D:\vcpkg-2026\buildtrees\glfw3\config-x64-windows-dbg-CMakeCache.txt.log
      D:\vcpkg-2026\buildtrees\glfw3\config-x64-windows-rel-CMakeCache.txt.log
      D:\vcpkg-2026\buildtrees\glfw3\config-x64-windows-dbg-CMakeConfigureLog.yaml.log
      D:\vcpkg-2026\buildtrees\glfw3\config-x64-windows-rel-CMakeConfigureLog.yaml.log
      D:\vcpkg-2026\buildtrees\glfw3\config-x64-windows-out.log

Call Stack (most recent call first):
  installed/x64-windows/share/vcpkg-cmake/vcpkg_cmake_configure.cmake:269 (vcpkg_execute_required_process)
  ports/glfw3/portfile.cmake:38 (vcpkg_cmake_configure)
  scripts/ports.cmake:209 (include)



```

<details><summary>D:\vcpkg-2026\buildtrees\glfw3\config-x64-windows-out.log</summary>

```
[1/2] "D:/vcpkg-2026/downloads/tools/cmake-4.4.0-windows/cmake-4.4.0-windows-x86_64/bin/cmake.exe" -E chdir ".." "D:/vcpkg-2026/downloads/tools/cmake-4.4.0-windows/cmake-4.4.0-windows-x86_64/bin/cmake.exe" "D:/vcpkg-2026/buildtrees/glfw3/src/3.4-2448ff4533.clean" "-G" "Ninja" "-DCMAKE_BUILD_TYPE=Release" "-DCMAKE_INSTALL_PREFIX=D:/vcpkg-2026/packages/glfw3_x64-windows" "-DFETCHCONTENT_FULLY_DISCONNECTED=ON" "-DGLFW_BUILD_EXAMPLES=OFF" "-DGLFW_BUILD_TESTS=OFF" "-DGLFW_BUILD_DOCS=OFF" "-DGLFW_BUILD_WAYLAND=OFF" "-DCMAKE_MAKE_PROGRAM=D:\software\VisualStdio26\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja\ninja.exe" "-DBUILD_SHARED_LIBS=ON" "-DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=D:/vcpkg-2026/scripts/toolchains/windows.cmake" "-DVCPKG_TARGET_TRIPLET=x64-windows" "-DVCPKG_SET_CHARSET_FLAG=ON" "-DVCPKG_PLATFORM_TOOLSET=v145" "-DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON" "-DCMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY=ON" "-DCMAKE_FIND_PACKAGE_NO_SYSTEM_PACKAGE_REGISTRY=ON" "-DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=TRUE" "-DCMAKE_VERBOSE_MAKEFILE=ON" "-DVCPKG_APPLOCAL_DEPS=OFF" "-DCMAKE_TOOLCHAIN_FILE=D:/vcpkg-2026/scripts/buildsystems/vcpkg.cmake" "-DCMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION=ON" "-DVCPKG_CXX_FLAGS=" "-DVCPKG_CXX_FLAGS_RELEASE=" "-DVCPKG_CXX_FLAGS_DEBUG=" "-DVCPKG_C_FLAGS=" "-DVCPKG_C_FLAGS_RELEASE=" "-DVCPKG_C_FLAGS_DEBUG=" "-DVCPKG_CRT_LINKAGE=dynamic" "-DVCPKG_LINKER_FLAGS=" "-DVCPKG_LINKER_FLAGS_RELEASE=" "-DVCPKG_LINKER_FLAGS_DEBUG=" "-DVCPKG_TARGET_ARCHITECTURE=x64" "-DCMAKE_INSTALL_LIBDIR:STRING=lib" "-DCMAKE_INSTALL_BINDIR:STRING=bin" "-D_VCPKG_ROOT_DIR=D:/vcpkg-2026" "-D_VCPKG_INSTALLED_DIR=D:/vcpkg-2026/installed" "-DVCPKG_MANIFEST_INSTALL=OFF"
FAILED: [code=1] ../CMakeCache.txt 
"D:/vcpkg-2026/downloads/tools/cmake-4.4.0-windows/cmake-4.4.0-windows-x86_64/bin/cmake.exe" -E chdir ".." "D:/vcpkg-2026/downloads/tools/cmake-4.4.0-windows/cmake-4.4.0-windows-x86_64/bin/cmake.exe" "D:/vcpkg-2026/buildtrees/glfw3/src/3.4-2448ff4533.clean" "-G" "Ninja" "-DCMAKE_BUILD_TYPE=Release" "-DCMAKE_INSTALL_PREFIX=D:/vcpkg-2026/packages/glfw3_x64-windows" "-DFETCHCONTENT_FULLY_DISCONNECTED=ON" "-DGLFW_BUILD_EXAMPLES=OFF" "-DGLFW_BUILD_TESTS=OFF" "-DGLFW_BUILD_DOCS=OFF" "-DGLFW_BUILD_WAYLAND=OFF" "-DCMAKE_MAKE_PROGRAM=D:\software\VisualStdio26\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja\ninja.exe" "-DBUILD_SHARED_LIBS=ON" "-DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=D:/vcpkg-2026/scripts/toolchains/windows.cmake" "-DVCPKG_TARGET_TRIPLET=x64-windows" "-DVCPKG_SET_CHARSET_FLAG=ON" "-DVCPKG_PLATFORM_TOOLSET=v145" "-DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON" "-DCMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY=ON" "-DCMAKE_FIND_PACKAGE_NO_SYSTEM_PACKAGE_REGISTRY=ON" "-DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=TRUE" "-DCMAKE_VERBOSE_MAKEFILE=ON" "-DVCPKG_APPLOCAL_DEPS=OFF" "-DCMAKE_TOOLCHAIN_FILE=D:/vcpkg-2026/scripts/buildsystems/vcpkg.cmake" "-DCMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION=ON" "-DVCPKG_CXX_FLAGS=" "-DVCPKG_CXX_FLAGS_RELEASE=" "-DVCPKG_CXX_FLAGS_DEBUG=" "-DVCPKG_C_FLAGS=" "-DVCPKG_C_FLAGS_RELEASE=" "-DVCPKG_C_FLAGS_DEBUG=" "-DVCPKG_CRT_LINKAGE=dynamic" "-DVCPKG_LINKER_FLAGS=" "-DVCPKG_LINKER_FLAGS_RELEASE=" "-DVCPKG_LINKER_FLAGS_DEBUG=" "-DVCPKG_TARGET_ARCHITECTURE=x64" "-DCMAKE_INSTALL_LIBDIR:STRING=lib" "-DCMAKE_INSTALL_BINDIR:STRING=bin" "-D_VCPKG_ROOT_DIR=D:/vcpkg-2026" "-D_VCPKG_INSTALLED_DIR=D:/vcpkg-2026/installed" "-DVCPKG_MANIFEST_INSTALL=OFF"
-- The C compiler identification is MSVC 19.51.36257.0
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - failed
-- Check for working C compiler: D:/software/VisualStdio26/VC/Tools/MSVC/14.51.36231/bin/Hostx64/x64/cl.exe
-- Check for working C compiler: D:/software/VisualStdio26/VC/Tools/MSVC/14.51.36231/bin/Hostx64/x64/cl.exe - broken
CMake Error at D:/vcpkg-2026/downloads/tools/cmake-4.4.0-windows/cmake-4.4.0-windows-x86_64/share/cmake-4.4/Modules/CMakeTestCCompiler.cmake:65 (message):
  The C compiler

    "D:/software/VisualStdio26/VC/Tools/MSVC/14.51.36231/bin/Hostx64/x64/cl.exe"

  is not able to compile a simple test program.

  It fails with the following output:

    Change Dir: 'D:/vcpkg-2026/buildtrees/glfw3/x64-windows-rel/CMakeFiles/CMakeScratch/TryCompile-vl6c1g'
    
    Run Build Command(s): D:\software\VisualStdio26\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja\ninja.exe -v cmTC_2ae44
    [1/2] D:\software\VisualStdio26\VC\Tools\MSVC\14.51.36231\bin\Hostx64\x64\cl.exe  /nologo -D_MBCS  /nologo /DWIN32 /D_WINDOWS /utf-8 /MP   /MDd /Z7 /Ob0 /Od /RTC1  -MDd /showIncludes /FoCMakeFiles\cmTC_2ae44.dir\testCCompiler.c.obj /FdCMakeFiles\cmTC_2ae44.dir\ /FS -c D:\vcpkg-2026\buildtrees\glfw3\x64-windows-rel\CMakeFiles\CMakeScratch\TryCompile-vl6c1g\testCCompiler.c
    FAILED: [code=2] CMakeFiles/cmTC_2ae44.dir/testCCompiler.c.obj 
    D:\software\VisualStdio26\VC\Tools\MSVC\14.51.36231\bin\Hostx64\x64\cl.exe  /nologo -D_MBCS  /nologo /DWIN32 /D_WINDOWS /utf-8 /MP   /MDd /Z7 /Ob0 /Od /RTC1  -MDd /showIncludes /FoCMakeFiles\cmTC_2ae44.dir\testCCompiler.c.obj /FdCMakeFiles\cmTC_2ae44.dir\ /FS -c D:\vcpkg-2026\buildtrees\glfw3\x64-windows-rel\CMakeFiles\CMakeScratch\TryCompile-vl6c1g\testCCompiler.c
    cl: 命令行 error D8050 :无法执行“D:\software\VisualStdio26\VC\Tools\MSVC\14.51.36231\bin\Hostx64\x64\c1.dll”: 未能将命令行放入调试记录中
    ninja: build stopped: subcommand failed.
    
    



  CMake will not be able to correctly generate this project.
Call Stack (most recent call first):
  CMakeLists.txt:3 (project)


-- Configuring incomplete, errors occurred!
[2/2] "D:/vcpkg-2026/downloads/tools/cmake-4.4.0-windows/cmake-4.4.0-windows-x86_64/bin/cmake.exe" -E chdir "../../x64-windows-dbg" "D:/vcpkg-2026/downloads/tools/cmake-4.4.0-windows/cmake-4.4.0-windows-x86_64/bin/cmake.exe" "D:/vcpkg-2026/buildtrees/glfw3/src/3.4-2448ff4533.clean" "-G" "Ninja" "-DCMAKE_BUILD_TYPE=Debug" "-DCMAKE_INSTALL_PREFIX=D:/vcpkg-2026/packages/glfw3_x64-windows/debug" "-DFETCHCONTENT_FULLY_DISCONNECTED=ON" "-DGLFW_BUILD_EXAMPLES=OFF" "-DGLFW_BUILD_TESTS=OFF" "-DGLFW_BUILD_DOCS=OFF" "-DGLFW_BUILD_WAYLAND=OFF" "-DCMAKE_MAKE_PROGRAM=D:\software\VisualStdio26\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja\ninja.exe" "-DBUILD_SHARED_LIBS=ON" "-DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=D:/vcpkg-2026/scripts/toolchains/windows.cmake" "-DVCPKG_TARGET_TRIPLET=x64-windows" "-DVCPKG_SET_CHARSET_FLAG=ON" "-DVCPKG_PLATFORM_TOOLSET=v145" "-DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON" "-DCMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY=ON" "-DCMAKE_FIND_PACKAGE_NO_SYSTEM_PACKAGE_REGISTRY=ON" "-DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=TRUE" "-DCMAKE_VERBOSE_MAKEFILE=ON" "-DVCPKG_APPLOCAL_DEPS=OFF" "-DCMAKE_TOOLCHAIN_FILE=D:/vcpkg-2026/scripts/buildsystems/vcpkg.cmake" "-DCMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION=ON" "-DVCPKG_CXX_FLAGS=" "-DVCPKG_CXX_FLAGS_RELEASE=" "-DVCPKG_CXX_FLAGS_DEBUG=" "-DVCPKG_C_FLAGS=" "-DVCPKG_C_FLAGS_RELEASE=" "-DVCPKG_C_FLAGS_DEBUG=" "-DVCPKG_CRT_LINKAGE=dynamic" "-DVCPKG_LINKER_FLAGS=" "-DVCPKG_LINKER_FLAGS_RELEASE=" "-DVCPKG_LINKER_FLAGS_DEBUG=" "-DVCPKG_TARGET_ARCHITECTURE=x64" "-DCMAKE_INSTALL_LIBDIR:STRING=lib" "-DCMAKE_INSTALL_BINDIR:STRING=bin" "-D_VCPKG_ROOT_DIR=D:/vcpkg-2026" "-D_VCPKG_INSTALLED_DIR=D:/vcpkg-2026/installed" "-DVCPKG_MANIFEST_INSTALL=OFF"
FAILED: [code=1] ../../x64-windows-dbg/CMakeCache.txt 
"D:/vcpkg-2026/downloads/tools/cmake-4.4.0-windows/cmake-4.4.0-windows-x86_64/bin/cmake.exe" -E chdir "../../x64-windows-dbg" "D:/vcpkg-2026/downloads/tools/cmake-4.4.0-windows/cmake-4.4.0-windows-x86_64/bin/cmake.exe" "D:/vcpkg-2026/buildtrees/glfw3/src/3.4-2448ff4533.clean" "-G" "Ninja" "-DCMAKE_BUILD_TYPE=Debug" "-DCMAKE_INSTALL_PREFIX=D:/vcpkg-2026/packages/glfw3_x64-windows/debug" "-DFETCHCONTENT_FULLY_DISCONNECTED=ON" "-DGLFW_BUILD_EXAMPLES=OFF" "-DGLFW_BUILD_TESTS=OFF" "-DGLFW_BUILD_DOCS=OFF" "-DGLFW_BUILD_WAYLAND=OFF" "-DCMAKE_MAKE_PROGRAM=D:\software\VisualStdio26\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja\ninja.exe" "-DBUILD_SHARED_LIBS=ON" "-DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=D:/vcpkg-2026/scripts/toolchains/windows.cmake" "-DVCPKG_TARGET_TRIPLET=x64-windows" "-DVCPKG_SET_CHARSET_FLAG=ON" "-DVCPKG_PLATFORM_TOOLSET=v145" "-DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON" "-DCMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY=ON" "-DCMAKE_FIND_PACKAGE_NO_SYSTEM_PACKAGE_REGISTRY=ON" "-DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=TRUE" "-DCMAKE_VERBOSE_MAKEFILE=ON" "-DVCPKG_APPLOCAL_DEPS=OFF" "-DCMAKE_TOOLCHAIN_FILE=D:/vcpkg-2026/scripts/buildsystems/vcpkg.cmake" "-DCMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION=ON" "-DVCPKG_CXX_FLAGS=" "-DVCPKG_CXX_FLAGS_RELEASE=" "-DVCPKG_CXX_FLAGS_DEBUG=" "-DVCPKG_C_FLAGS=" "-DVCPKG_C_FLAGS_RELEASE=" "-DVCPKG_C_FLAGS_DEBUG=" "-DVCPKG_CRT_LINKAGE=dynamic" "-DVCPKG_LINKER_FLAGS=" "-DVCPKG_LINKER_FLAGS_RELEASE=" "-DVCPKG_LINKER_FLAGS_DEBUG=" "-DVCPKG_TARGET_ARCHITECTURE=x64" "-DCMAKE_INSTALL_LIBDIR:STRING=lib" "-DCMAKE_INSTALL_BINDIR:STRING=bin" "-D_VCPKG_ROOT_DIR=D:/vcpkg-2026" "-D_VCPKG_INSTALLED_DIR=D:/vcpkg-2026/installed" "-DVCPKG_MANIFEST_INSTALL=OFF"
-- The C compiler identification is MSVC 19.51.36257.0
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - failed
-- Check for working C compiler: D:/software/VisualStdio26/VC/Tools/MSVC/14.51.36231/bin/Hostx64/x64/cl.exe
-- Check for working C compiler: D:/software/VisualStdio26/VC/Tools/MSVC/14.51.36231/bin/Hostx64/x64/cl.exe - broken
CMake Error at D:/vcpkg-2026/downloads/tools/cmake-4.4.0-windows/cmake-4.4.0-windows-x86_64/share/cmake-4.4/Modules/CMakeTestCCompiler.cmake:65 (message):
  The C compiler

    "D:/software/VisualStdio26/VC/Tools/MSVC/14.51.36231/bin/Hostx64/x64/cl.exe"

  is not able to compile a simple test program.

  It fails with the following output:

    Change Dir: 'D:/vcpkg-2026/buildtrees/glfw3/x64-windows-dbg/CMakeFiles/CMakeScratch/TryCompile-vigpi7'
    
    Run Build Command(s): D:\software\VisualStdio26\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja\ninja.exe -v cmTC_e1d35
    [1/2] D:\software\VisualStdio26\VC\Tools\MSVC\14.51.36231\bin\Hostx64\x64\cl.exe  /nologo -D_MBCS  /nologo /DWIN32 /D_WINDOWS /utf-8 /MP   /MDd /Z7 /Ob0 /Od /RTC1  -MDd /showIncludes /FoCMakeFiles\cmTC_e1d35.dir\testCCompiler.c.obj /FdCMakeFiles\cmTC_e1d35.dir\ /FS -c D:\vcpkg-2026\buildtrees\glfw3\x64-windows-dbg\CMakeFiles\CMakeScratch\TryCompile-vigpi7\testCCompiler.c
    FAILED: [code=2] CMakeFiles/cmTC_e1d35.dir/testCCompiler.c.obj 
    D:\software\VisualStdio26\VC\Tools\MSVC\14.51.36231\bin\Hostx64\x64\cl.exe  /nologo -D_MBCS  /nologo /DWIN32 /D_WINDOWS /utf-8 /MP   /MDd /Z7 /Ob0 /Od /RTC1  -MDd /showIncludes /FoCMakeFiles\cmTC_e1d35.dir\testCCompiler.c.obj /FdCMakeFiles\cmTC_e1d35.dir\ /FS -c D:\vcpkg-2026\buildtrees\glfw3\x64-windows-dbg\CMakeFiles\CMakeScratch\TryCompile-vigpi7\testCCompiler.c
    cl: 命令行 error D8050 :无法执行“D:\software\VisualStdio26\VC\Tools\MSVC\14.51.36231\bin\Hostx64\x64\c1.dll”: 未能将命令行放入调试记录中
    ninja: build stopped: subcommand failed.
    
    



  CMake will not be able to correctly generate this project.
Call Stack (most recent call first):
  CMakeLists.txt:3 (project)


-- Configuring incomplete, errors occurred!
ninja: build stopped: subcommand failed.
```
</details>

<details><summary>D:\vcpkg-2026\buildtrees\glfw3\config-x64-windows-rel-CMakeCache.txt.log</summary>

```
# This is the CMakeCache file.
# For build in directory: d:/vcpkg-2026/buildtrees/glfw3/x64-windows-rel
# It was generated by CMake: D:/vcpkg-2026/downloads/tools/cmake-4.4.0-windows/cmake-4.4.0-windows-x86_64/bin/cmake.exe
# You can edit this file to change values found and used by cmake.
# If you do not want to change any of the values, simply exit the editor.
# If you do want to change a value, simply edit, save, and exit the editor.
# The syntax for the file is as follows:
# KEY:TYPE=VALUE
# KEY is the name of a variable in the cache.
# TYPE is a hint to GUIs for the type of VALUE, DO NOT EDIT TYPE!.
# VALUE is the current value for the KEY.

########################
# EXTERNAL cache entries
########################

//Global default for the library type used by add_library() when
// no STATIC/SHARED keyword is given: SHARED if true, STATIC otherwise.
// Not defined by CMake itself; commonly exposed as an option()
// by projects.
BUILD_SHARED_LIBS:UNINITIALIZED=ON

//Path to a program.
CMAKE_AR:FILEPATH=D:/software/VisualStdio26/VC/Tools/MSVC/14.51.36231/bin/Hostx64/x64/lib.exe

//Choose the type of build, options are: None Debug Release RelWithDebInfo
// MinSizeRel ...
CMAKE_BUILD_TYPE:STRING=Release

CMAKE_CROSSCOMPILING:STRING=OFF

CMAKE_CXX_FLAGS:STRING=' /nologo /DWIN32 /D_WINDOWS /utf-8 /GR /EHsc /MP '

CMAKE_CXX_FLAGS_DEBUG:STRING='/MDd /Z7 /Ob0 /Od /RTC1 '

CMAKE_CXX_FLAGS_RELEASE:STRING='/MD /O2 /Oi /Gy /DNDEBUG /Z7 '

//C compiler
CMAKE_C_COMPILER:FILEPATH=D:/software/VisualStdio26/VC/Tools/MSVC/14.51.36231/bin/Hostx64/x64/cl.exe

CMAKE_C_FLAGS:STRING=' /nologo /DWIN32 /D_WINDOWS /utf-8 /MP '

CMAKE_C_FLAGS_DEBUG:STRING='/MDd /Z7 /Ob0 /Od /RTC1 '

//Flags used by the C compiler during MINSIZEREL builds.
CMAKE_C_FLAGS_MINSIZEREL:STRING=/O1 /Ob1 /DNDEBUG

CMAKE_C_FLAGS_RELEASE:STRING='/MD /O2 /Oi /Gy /DNDEBUG /Z7 '

//Flags used by the C compiler during RELWITHDEBINFO builds.
CMAKE_C_FLAGS_RELWITHDEBINFO:STRING=/O2 /Ob1 /DNDEBUG

//Libraries linked by default with all C applications.
CMAKE_C_STANDARD_LIBRARIES:STRING=kernel32.lib user32.lib gdi32.lib winspool.lib shell32.lib ole32.lib oleaut32.lib uuid.lib comdlg32.lib advapi32.lib

//Error when cmake_install.cmake encounters absolute INSTALL DESTINATION.
CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION:UNINITIALIZED=ON

//Flags used by the linker during all build types.
CMAKE_EXE_LINKER_FLAGS:STRING=/machine:x64

//Flags used by the linker during DEBUG builds.
CMAKE_EXE_LINKER_FLAGS_DEBUG:STRING=/nologo    /debug /INCREMENTAL

//Flags used by the linker during MINSIZEREL builds.
CMAKE_EXE_LINKER_FLAGS_MINSIZEREL:STRING=/INCREMENTAL:NO

CMAKE_EXE_LINKER_FLAGS_RELEASE:STRING='/nologo /DEBUG /INCREMENTAL:NO /OPT:REF /OPT:ICF  '

//Flags used by the linker during RELWITHDEBINFO builds.
CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO:STRING=/debug /INCREMENTAL

//Enable/Disable output of build database during the build.
CMAKE_EXPORT_BUILD_DATABASE:BOOL=

//Enable/Disable output of compile commands during generation.
CMAKE_EXPORT_COMPILE_COMMANDS:BOOL=

//Disable the export(PACKAGE) command from writing to the user
// package registry when CMP0090 is not set to NEW.
CMAKE_EXPORT_NO_PACKAGE_REGISTRY:UNINITIALIZED=ON

//DEPRECATED: Use CMAKE_FIND_USE_PACKAGE_REGISTRY instead. When
// unset, find_package uses User Package Registry unless disabled.
// Ignored if CMAKE_FIND_USE_PACKAGE_REGISTRY is set.
CMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY:UNINITIALIZED=ON

//DEPRECATED: Use CMAKE_FIND_USE_SYSTEM_PACKAGE_REGISTRY instead.
// When unset, find_package uses System Package Registry unless
// disabled. Ignored if CMAKE_FIND_USE_SYSTEM_PACKAGE_REGISTRY
// is set.
CMAKE_FIND_PACKAGE_NO_SYSTEM_PACKAGE_REGISTRY:UNINITIALIZED=ON

//Value Computed by CMake.
CMAKE_FIND_PACKAGE_REDIRECTS_DIR:STATIC=D:/vcpkg-2026/buildtrees/glfw3/x64-windows-rel/CMakeFiles/pkgRedirects

//No help, variable specified on the command line.
CMAKE_INSTALL_BINDIR:STRING=bin

//No help, variable specified on the command line.
CMAKE_INSTALL_LIBDIR:STRING=lib

//Install path prefix, prepended onto install directories.
CMAKE_INSTALL_PREFIX:PATH=D:/vcpkg-2026/packages/glfw3_x64-windows

//No help, variable specified on the command line.
CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP:UNINITIALIZED=TRUE

//Path to a program.
CMAKE_LINKER:FILEPATH=D:/software/VisualStdio26/VC/Tools/MSVC/14.51.36231/bin/Hostx64/x64/link.exe

//Tool that can launch the native build system. The value may be
// the full path to an executable or just the tool name if it is
...
Skipped 210 lines
...

//Appends the vcpkg paths to CMAKE_PREFIX_PATH, CMAKE_LIBRARY_PATH
// and CMAKE_FIND_ROOT_PATH so that vcpkg libraries/packages are
// found after toolchain/system libraries/packages.
VCPKG_PREFER_SYSTEM_LIBS:BOOL=OFF

//Enable the setup of CMAKE_PROGRAM_PATH to vcpkg paths
VCPKG_SETUP_CMAKE_PROGRAM_PATH:BOOL=ON

//No help, variable specified on the command line.
VCPKG_SET_CHARSET_FLAG:UNINITIALIZED=ON

//No help, variable specified on the command line.
VCPKG_TARGET_ARCHITECTURE:UNINITIALIZED=x64

//Vcpkg target triplet (ex. x86-windows)
VCPKG_TARGET_TRIPLET:STRING=x64-windows

//Trace calls to find_package()
VCPKG_TRACE_FIND_PACKAGE:BOOL=OFF

//Use applocal.ps1 instead of vcpkg z-applocal.
VCPKG_USE_LEGACY_APPLOCAL:BOOL=OFF

//Enables messages from the VCPKG toolchain for debugging purposes.
VCPKG_VERBOSE:BOOL=OFF

//(experimental) Automatically copy dependencies into the install
// target directory for executables. Requires CMake 3.14.
X_VCPKG_APPLOCAL_DEPS_INSTALL:BOOL=OFF

//(experimental) Add USES_TERMINAL to VCPKG_APPLOCAL_DEPS to force
// serialization.
X_VCPKG_APPLOCAL_DEPS_SERIALIZED:BOOL=OFF

//The directory which contains the installed libraries for each
// triplet
_VCPKG_INSTALLED_DIR:PATH=D:/vcpkg-2026/installed

//No help, variable specified on the command line.
_VCPKG_ROOT_DIR:UNINITIALIZED=D:/vcpkg-2026


########################
# INTERNAL cache entries
########################

//ADVANCED property for variable: CMAKE_AR
CMAKE_AR-ADVANCED:INTERNAL=1
//This is the directory where this CMakeCache.txt was created
CMAKE_CACHEFILE_DIR:INTERNAL=d:/vcpkg-2026/buildtrees/glfw3/x64-windows-rel
//Major version of cmake used to create the current loaded cache
CMAKE_CACHE_MAJOR_VERSION:INTERNAL=4
//Minor version of cmake used to create the current loaded cache
CMAKE_CACHE_MINOR_VERSION:INTERNAL=4
//Patch version of cmake used to create the current loaded cache
CMAKE_CACHE_PATCH_VERSION:INTERNAL=0
//Path to CMake executable.
CMAKE_COMMAND:INTERNAL=D:/vcpkg-2026/downloads/tools/cmake-4.4.0-windows/cmake-4.4.0-windows-x86_64/bin/cmake.exe
//Path to cpack program executable.
CMAKE_CPACK_COMMAND:INTERNAL=D:/vcpkg-2026/downloads/tools/cmake-4.4.0-windows/cmake-4.4.0-windows-x86_64/bin/cpack.exe
//Path to ctest program executable.
CMAKE_CTEST_COMMAND:INTERNAL=D:/vcpkg-2026/downloads/tools/cmake-4.4.0-windows/cmake-4.4.0-windows-x86_64/bin/ctest.exe
//ADVANCED property for variable: CMAKE_C_COMPILER
CMAKE_C_COMPILER-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_C_FLAGS
CMAKE_C_FLAGS-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_C_FLAGS_DEBUG
CMAKE_C_FLAGS_DEBUG-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_C_FLAGS_MINSIZEREL
CMAKE_C_FLAGS_MINSIZEREL-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_C_FLAGS_RELEASE
CMAKE_C_FLAGS_RELEASE-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_C_FLAGS_RELWITHDEBINFO
CMAKE_C_FLAGS_RELWITHDEBINFO-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_C_STANDARD_LIBRARIES
CMAKE_C_STANDARD_LIBRARIES-ADVANCED:INTERNAL=1
//Set initial state for CMake diagnostics; used to persist state
// set by command-line options across invocations.
CMAKE_DIAGNOSTIC_INIT:INTERNAL=CMD_AUTHOR=WARN;CMD_DEPRECATED=WARN;CMD_EXPERIMENTAL=WARN;CMD_INSTALL_ABSOLUTE_DESTINATION=IGNORE;CMD_POLICY=WARN;CMD_UNINITIALIZED=IGNORE;CMD_UNUSED_CLI=WARN
//Path to cache edit program executable.
CMAKE_EDIT_COMMAND:INTERNAL=D:/vcpkg-2026/downloads/tools/cmake-4.4.0-windows/cmake-4.4.0-windows-x86_64/bin/cmake-gui.exe
//Deprecated.  Use -W[no-]error=deprecated instead.
CMAKE_ERROR_DEPRECATED:INTERNAL=OFF
//Executable file format
CMAKE_EXECUTABLE_FORMAT:INTERNAL=Unknown
//ADVANCED property for variable: CMAKE_EXE_LINKER_FLAGS
CMAKE_EXE_LINKER_FLAGS-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_EXE_LINKER_FLAGS_DEBUG
CMAKE_EXE_LINKER_FLAGS_DEBUG-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_EXE_LINKER_FLAGS_MINSIZEREL
CMAKE_EXE_LINKER_FLAGS_MINSIZEREL-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_EXE_LINKER_FLAGS_RELEASE
CMAKE_EXE_LINKER_FLAGS_RELEASE-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO
CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_EXPORT_BUILD_DATABASE
CMAKE_EXPORT_BUILD_DATABASE-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_EXPORT_COMPILE_COMMANDS
CMAKE_EXPORT_COMPILE_COMMANDS-ADVANCED:INTERNAL=1
//Name of external makefile project generator.
CMAKE_EXTRA_GENERATOR:INTERNAL=
//Name of generator.
CMAKE_GENERATOR:INTERNAL=Ninja
//Generator instance identifier.
CMAKE_GENERATOR_INSTANCE:INTERNAL=
//Name of generator platform.
CMAKE_GENERATOR_PLATFORM:INTERNAL=
//Name of generator toolset.
CMAKE_GENERATOR_TOOLSET:INTERNAL=
//Source directory with the top level CMakeLists.txt file for this
// project
CMAKE_HOME_DIRECTORY:INTERNAL=D:/vcpkg-2026/buildtrees/glfw3/src/3.4-2448ff4533.clean
//ADVANCED property for variable: CMAKE_LINKER
CMAKE_LINKER-ADVANCED:INTERNAL=1
//Name of CMakeLists files to read
CMAKE_LIST_FILE_NAME:INTERNAL=CMakeLists.txt
//ADVANCED property for variable: CMAKE_MODULE_LINKER_FLAGS
CMAKE_MODULE_LINKER_FLAGS-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_MODULE_LINKER_FLAGS_DEBUG
CMAKE_MODULE_LINKER_FLAGS_DEBUG-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_MODULE_LINKER_FLAGS_MINSIZEREL
CMAKE_MODULE_LINKER_FLAGS_MINSIZEREL-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_MODULE_LINKER_FLAGS_RELEASE
CMAKE_MODULE_LINKER_FLAGS_RELEASE-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO
CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_MT
CMAKE_MT-ADVANCED:INTERNAL=1
//number of local generators
CMAKE_NUMBER_OF_MAKEFILES:INTERNAL=1
//Platform information initialized
CMAKE_PLATFORM_INFO_INITIALIZED:INTERNAL=1
//ADVANCED property for variable: CMAKE_POLICY_VERSION_MINIMUM
CMAKE_POLICY_VERSION_MINIMUM-ADVANCED:INTERNAL=1
//noop for ranlib
CMAKE_RANLIB:INTERNAL=:
//ADVANCED property for variable: CMAKE_RC_COMPILER
CMAKE_RC_COMPILER-ADVANCED:INTERNAL=1
CMAKE_RC_COMPILER_WORKS:INTERNAL=1
//ADVANCED property for variable: CMAKE_RC_FLAGS
CMAKE_RC_FLAGS-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_RC_FLAGS_DEBUG
CMAKE_RC_FLAGS_DEBUG-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_RC_FLAGS_MINSIZEREL
CMAKE_RC_FLAGS_MINSIZEREL-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_RC_FLAGS_RELEASE
CMAKE_RC_FLAGS_RELEASE-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_RC_FLAGS_RELWITHDEBINFO
CMAKE_RC_FLAGS_RELWITHDEBINFO-ADVANCED:INTERNAL=1
//Path to CMake installation.
CMAKE_ROOT:INTERNAL=D:/vcpkg-2026/downloads/tools/cmake-4.4.0-windows/cmake-4.4.0-windows-x86_64/share/cmake-4.4
//ADVANCED property for variable: CMAKE_SHARED_LINKER_FLAGS
CMAKE_SHARED_LINKER_FLAGS-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_SHARED_LINKER_FLAGS_DEBUG
CMAKE_SHARED_LINKER_FLAGS_DEBUG-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL
CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_SHARED_LINKER_FLAGS_RELEASE
CMAKE_SHARED_LINKER_FLAGS_RELEASE-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO
CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_SKIP_INSTALL_RPATH
CMAKE_SKIP_INSTALL_RPATH-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_SKIP_RPATH
CMAKE_SKIP_RPATH-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_STATIC_LINKER_FLAGS
CMAKE_STATIC_LINKER_FLAGS-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_STATIC_LINKER_FLAGS_DEBUG
CMAKE_STATIC_LINKER_FLAGS_DEBUG-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_STATIC_LINKER_FLAGS_MINSIZEREL
CMAKE_STATIC_LINKER_FLAGS_MINSIZEREL-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_STATIC_LINKER_FLAGS_RELEASE
CMAKE_STATIC_LINKER_FLAGS_RELEASE-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_STATIC_LINKER_FLAGS_RELWITHDEBINFO
CMAKE_STATIC_LINKER_FLAGS_RELWITHDEBINFO-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_TOOLCHAIN_FILE
CMAKE_TOOLCHAIN_FILE-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_VERBOSE_MAKEFILE
CMAKE_VERBOSE_MAKEFILE-ADVANCED:INTERNAL=1
//Deprecated.  Use -W[no-]deprecated instead.
CMAKE_WARN_DEPRECATED:INTERNAL=ON
//Install the dependencies listed in your manifest:
//\n    If this is off, you will have to manually install your dependencies.
//\n    See https://github.com/microsoft/vcpkg/tree/master/docs/specifications/manifests.md
// for more info.
//\n
VCPKG_MANIFEST_INSTALL:INTERNAL=OFF
//ADVANCED property for variable: VCPKG_VERBOSE
VCPKG_VERBOSE-ADVANCED:INTERNAL=1
//Making sure VCPKG_MANIFEST_MODE doesn't change
Z_VCPKG_CHECK_MANIFEST_MODE:INTERNAL=OFF
//Vcpkg root directory
Z_VCPKG_ROOT_DIR:INTERNAL=D:/vcpkg-2026

```
</details>

<details><summary>D:\vcpkg-2026\buildtrees\glfw3\config-x64-windows-dbg-CMakeCache.txt.log</summary>

```
# This is the CMakeCache file.
# For build in directory: d:/vcpkg-2026/buildtrees/glfw3/x64-windows-dbg
# It was generated by CMake: D:/vcpkg-2026/downloads/tools/cmake-4.4.0-windows/cmake-4.4.0-windows-x86_64/bin/cmake.exe
# You can edit this file to change values found and used by cmake.
# If you do not want to change any of the values, simply exit the editor.
# If you do want to change a value, simply edit, save, and exit the editor.
# The syntax for the file is as follows:
# KEY:TYPE=VALUE
# KEY is the name of a variable in the cache.
# TYPE is a hint to GUIs for the type of VALUE, DO NOT EDIT TYPE!.
# VALUE is the current value for the KEY.

########################
# EXTERNAL cache entries
########################

//Global default for the library type used by add_library() when
// no STATIC/SHARED keyword is given: SHARED if true, STATIC otherwise.
// Not defined by CMake itself; commonly exposed as an option()
// by projects.
BUILD_SHARED_LIBS:UNINITIALIZED=ON

//Path to a program.
CMAKE_AR:FILEPATH=D:/software/VisualStdio26/VC/Tools/MSVC/14.51.36231/bin/Hostx64/x64/lib.exe

//Choose the type of build, options are: None Debug Release RelWithDebInfo
// MinSizeRel ...
CMAKE_BUILD_TYPE:STRING=Debug

CMAKE_CROSSCOMPILING:STRING=OFF

CMAKE_CXX_FLAGS:STRING=' /nologo /DWIN32 /D_WINDOWS /utf-8 /GR /EHsc /MP '

CMAKE_CXX_FLAGS_DEBUG:STRING='/MDd /Z7 /Ob0 /Od /RTC1 '

CMAKE_CXX_FLAGS_RELEASE:STRING='/MD /O2 /Oi /Gy /DNDEBUG /Z7 '

//C compiler
CMAKE_C_COMPILER:FILEPATH=D:/software/VisualStdio26/VC/Tools/MSVC/14.51.36231/bin/Hostx64/x64/cl.exe

CMAKE_C_FLAGS:STRING=' /nologo /DWIN32 /D_WINDOWS /utf-8 /MP '

CMAKE_C_FLAGS_DEBUG:STRING='/MDd /Z7 /Ob0 /Od /RTC1 '

//Flags used by the C compiler during MINSIZEREL builds.
CMAKE_C_FLAGS_MINSIZEREL:STRING=/O1 /Ob1 /DNDEBUG

CMAKE_C_FLAGS_RELEASE:STRING='/MD /O2 /Oi /Gy /DNDEBUG /Z7 '

//Flags used by the C compiler during RELWITHDEBINFO builds.
CMAKE_C_FLAGS_RELWITHDEBINFO:STRING=/O2 /Ob1 /DNDEBUG

//Libraries linked by default with all C applications.
CMAKE_C_STANDARD_LIBRARIES:STRING=kernel32.lib user32.lib gdi32.lib winspool.lib shell32.lib ole32.lib oleaut32.lib uuid.lib comdlg32.lib advapi32.lib

//Error when cmake_install.cmake encounters absolute INSTALL DESTINATION.
CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION:UNINITIALIZED=ON

//Flags used by the linker during all build types.
CMAKE_EXE_LINKER_FLAGS:STRING=/machine:x64

//Flags used by the linker during DEBUG builds.
CMAKE_EXE_LINKER_FLAGS_DEBUG:STRING=/nologo    /debug /INCREMENTAL

//Flags used by the linker during MINSIZEREL builds.
CMAKE_EXE_LINKER_FLAGS_MINSIZEREL:STRING=/INCREMENTAL:NO

CMAKE_EXE_LINKER_FLAGS_RELEASE:STRING='/nologo /DEBUG /INCREMENTAL:NO /OPT:REF /OPT:ICF  '

//Flags used by the linker during RELWITHDEBINFO builds.
CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO:STRING=/debug /INCREMENTAL

//Enable/Disable output of build database during the build.
CMAKE_EXPORT_BUILD_DATABASE:BOOL=

//Enable/Disable output of compile commands during generation.
CMAKE_EXPORT_COMPILE_COMMANDS:BOOL=

//Disable the export(PACKAGE) command from writing to the user
// package registry when CMP0090 is not set to NEW.
CMAKE_EXPORT_NO_PACKAGE_REGISTRY:UNINITIALIZED=ON

//DEPRECATED: Use CMAKE_FIND_USE_PACKAGE_REGISTRY instead. When
// unset, find_package uses User Package Registry unless disabled.
// Ignored if CMAKE_FIND_USE_PACKAGE_REGISTRY is set.
CMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY:UNINITIALIZED=ON

//DEPRECATED: Use CMAKE_FIND_USE_SYSTEM_PACKAGE_REGISTRY instead.
// When unset, find_package uses System Package Registry unless
// disabled. Ignored if CMAKE_FIND_USE_SYSTEM_PACKAGE_REGISTRY
// is set.
CMAKE_FIND_PACKAGE_NO_SYSTEM_PACKAGE_REGISTRY:UNINITIALIZED=ON

//Value Computed by CMake.
CMAKE_FIND_PACKAGE_REDIRECTS_DIR:STATIC=D:/vcpkg-2026/buildtrees/glfw3/x64-windows-dbg/CMakeFiles/pkgRedirects

//No help, variable specified on the command line.
CMAKE_INSTALL_BINDIR:STRING=bin

//No help, variable specified on the command line.
CMAKE_INSTALL_LIBDIR:STRING=lib

//Install path prefix, prepended onto install directories.
...
Skipped 248 lines
...
// target directory for executables. Requires CMake 3.14.
X_VCPKG_APPLOCAL_DEPS_INSTALL:BOOL=OFF

//(experimental) Add USES_TERMINAL to VCPKG_APPLOCAL_DEPS to force
// serialization.
X_VCPKG_APPLOCAL_DEPS_SERIALIZED:BOOL=OFF

//The directory which contains the installed libraries for each
// triplet
_VCPKG_INSTALLED_DIR:PATH=D:/vcpkg-2026/installed

//No help, variable specified on the command line.
_VCPKG_ROOT_DIR:UNINITIALIZED=D:/vcpkg-2026


########################
# INTERNAL cache entries
########################

//ADVANCED property for variable: CMAKE_AR
CMAKE_AR-ADVANCED:INTERNAL=1
//This is the directory where this CMakeCache.txt was created
CMAKE_CACHEFILE_DIR:INTERNAL=d:/vcpkg-2026/buildtrees/glfw3/x64-windows-dbg
//Major version of cmake used to create the current loaded cache
CMAKE_CACHE_MAJOR_VERSION:INTERNAL=4
//Minor version of cmake used to create the current loaded cache
CMAKE_CACHE_MINOR_VERSION:INTERNAL=4
//Patch version of cmake used to create the current loaded cache
CMAKE_CACHE_PATCH_VERSION:INTERNAL=0
//Path to CMake executable.
CMAKE_COMMAND:INTERNAL=D:/vcpkg-2026/downloads/tools/cmake-4.4.0-windows/cmake-4.4.0-windows-x86_64/bin/cmake.exe
//Path to cpack program executable.
CMAKE_CPACK_COMMAND:INTERNAL=D:/vcpkg-2026/downloads/tools/cmake-4.4.0-windows/cmake-4.4.0-windows-x86_64/bin/cpack.exe
//Path to ctest program executable.
CMAKE_CTEST_COMMAND:INTERNAL=D:/vcpkg-2026/downloads/tools/cmake-4.4.0-windows/cmake-4.4.0-windows-x86_64/bin/ctest.exe
//ADVANCED property for variable: CMAKE_C_COMPILER
CMAKE_C_COMPILER-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_C_FLAGS
CMAKE_C_FLAGS-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_C_FLAGS_DEBUG
CMAKE_C_FLAGS_DEBUG-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_C_FLAGS_MINSIZEREL
CMAKE_C_FLAGS_MINSIZEREL-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_C_FLAGS_RELEASE
CMAKE_C_FLAGS_RELEASE-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_C_FLAGS_RELWITHDEBINFO
CMAKE_C_FLAGS_RELWITHDEBINFO-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_C_STANDARD_LIBRARIES
CMAKE_C_STANDARD_LIBRARIES-ADVANCED:INTERNAL=1
//Set initial state for CMake diagnostics; used to persist state
// set by command-line options across invocations.
CMAKE_DIAGNOSTIC_INIT:INTERNAL=CMD_AUTHOR=WARN;CMD_DEPRECATED=WARN;CMD_EXPERIMENTAL=WARN;CMD_INSTALL_ABSOLUTE_DESTINATION=IGNORE;CMD_POLICY=WARN;CMD_UNINITIALIZED=IGNORE;CMD_UNUSED_CLI=WARN
//Path to cache edit program executable.
CMAKE_EDIT_COMMAND:INTERNAL=D:/vcpkg-2026/downloads/tools/cmake-4.4.0-windows/cmake-4.4.0-windows-x86_64/bin/cmake-gui.exe
//Deprecated.  Use -W[no-]error=deprecated instead.
CMAKE_ERROR_DEPRECATED:INTERNAL=OFF
//Executable file format
CMAKE_EXECUTABLE_FORMAT:INTERNAL=Unknown
//ADVANCED property for variable: CMAKE_EXE_LINKER_FLAGS
CMAKE_EXE_LINKER_FLAGS-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_EXE_LINKER_FLAGS_DEBUG
CMAKE_EXE_LINKER_FLAGS_DEBUG-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_EXE_LINKER_FLAGS_MINSIZEREL
CMAKE_EXE_LINKER_FLAGS_MINSIZEREL-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_EXE_LINKER_FLAGS_RELEASE
CMAKE_EXE_LINKER_FLAGS_RELEASE-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO
CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_EXPORT_BUILD_DATABASE
CMAKE_EXPORT_BUILD_DATABASE-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_EXPORT_COMPILE_COMMANDS
CMAKE_EXPORT_COMPILE_COMMANDS-ADVANCED:INTERNAL=1
//Name of external makefile project generator.
CMAKE_EXTRA_GENERATOR:INTERNAL=
//Name of generator.
CMAKE_GENERATOR:INTERNAL=Ninja
//Generator instance identifier.
CMAKE_GENERATOR_INSTANCE:INTERNAL=
//Name of generator platform.
CMAKE_GENERATOR_PLATFORM:INTERNAL=
//Name of generator toolset.
CMAKE_GENERATOR_TOOLSET:INTERNAL=
//Source directory with the top level CMakeLists.txt file for this
// project
CMAKE_HOME_DIRECTORY:INTERNAL=D:/vcpkg-2026/buildtrees/glfw3/src/3.4-2448ff4533.clean
//ADVANCED property for variable: CMAKE_LINKER
CMAKE_LINKER-ADVANCED:INTERNAL=1
//Name of CMakeLists files to read
CMAKE_LIST_FILE_NAME:INTERNAL=CMakeLists.txt
//ADVANCED property for variable: CMAKE_MODULE_LINKER_FLAGS
CMAKE_MODULE_LINKER_FLAGS-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_MODULE_LINKER_FLAGS_DEBUG
CMAKE_MODULE_LINKER_FLAGS_DEBUG-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_MODULE_LINKER_FLAGS_MINSIZEREL
CMAKE_MODULE_LINKER_FLAGS_MINSIZEREL-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_MODULE_LINKER_FLAGS_RELEASE
CMAKE_MODULE_LINKER_FLAGS_RELEASE-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO
CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_MT
CMAKE_MT-ADVANCED:INTERNAL=1
//number of local generators
CMAKE_NUMBER_OF_MAKEFILES:INTERNAL=1
//Platform information initialized
CMAKE_PLATFORM_INFO_INITIALIZED:INTERNAL=1
//ADVANCED property for variable: CMAKE_POLICY_VERSION_MINIMUM
CMAKE_POLICY_VERSION_MINIMUM-ADVANCED:INTERNAL=1
//noop for ranlib
CMAKE_RANLIB:INTERNAL=:
//ADVANCED property for variable: CMAKE_RC_COMPILER
CMAKE_RC_COMPILER-ADVANCED:INTERNAL=1
CMAKE_RC_COMPILER_WORKS:INTERNAL=1
//ADVANCED property for variable: CMAKE_RC_FLAGS
CMAKE_RC_FLAGS-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_RC_FLAGS_DEBUG
CMAKE_RC_FLAGS_DEBUG-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_RC_FLAGS_MINSIZEREL
CMAKE_RC_FLAGS_MINSIZEREL-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_RC_FLAGS_RELEASE
CMAKE_RC_FLAGS_RELEASE-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_RC_FLAGS_RELWITHDEBINFO
CMAKE_RC_FLAGS_RELWITHDEBINFO-ADVANCED:INTERNAL=1
//Path to CMake installation.
CMAKE_ROOT:INTERNAL=D:/vcpkg-2026/downloads/tools/cmake-4.4.0-windows/cmake-4.4.0-windows-x86_64/share/cmake-4.4
//ADVANCED property for variable: CMAKE_SHARED_LINKER_FLAGS
CMAKE_SHARED_LINKER_FLAGS-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_SHARED_LINKER_FLAGS_DEBUG
CMAKE_SHARED_LINKER_FLAGS_DEBUG-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL
CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_SHARED_LINKER_FLAGS_RELEASE
CMAKE_SHARED_LINKER_FLAGS_RELEASE-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO
CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_SKIP_INSTALL_RPATH
CMAKE_SKIP_INSTALL_RPATH-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_SKIP_RPATH
CMAKE_SKIP_RPATH-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_STATIC_LINKER_FLAGS
CMAKE_STATIC_LINKER_FLAGS-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_STATIC_LINKER_FLAGS_DEBUG
CMAKE_STATIC_LINKER_FLAGS_DEBUG-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_STATIC_LINKER_FLAGS_MINSIZEREL
CMAKE_STATIC_LINKER_FLAGS_MINSIZEREL-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_STATIC_LINKER_FLAGS_RELEASE
CMAKE_STATIC_LINKER_FLAGS_RELEASE-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_STATIC_LINKER_FLAGS_RELWITHDEBINFO
CMAKE_STATIC_LINKER_FLAGS_RELWITHDEBINFO-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_TOOLCHAIN_FILE
CMAKE_TOOLCHAIN_FILE-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_VERBOSE_MAKEFILE
CMAKE_VERBOSE_MAKEFILE-ADVANCED:INTERNAL=1
//Deprecated.  Use -W[no-]deprecated instead.
CMAKE_WARN_DEPRECATED:INTERNAL=ON
//Install the dependencies listed in your manifest:
//\n    If this is off, you will have to manually install your dependencies.
//\n    See https://github.com/microsoft/vcpkg/tree/master/docs/specifications/manifests.md
// for more info.
//\n
VCPKG_MANIFEST_INSTALL:INTERNAL=OFF
//ADVANCED property for variable: VCPKG_VERBOSE
VCPKG_VERBOSE-ADVANCED:INTERNAL=1
//Making sure VCPKG_MANIFEST_MODE doesn't change
Z_VCPKG_CHECK_MANIFEST_MODE:INTERNAL=OFF
//Vcpkg root directory
Z_VCPKG_ROOT_DIR:INTERNAL=D:/vcpkg-2026

```
</details>

<details><summary>D:\vcpkg-2026\buildtrees\glfw3\config-x64-windows-rel-CMakeConfigureLog.yaml.log</summary>

```

---
events:
  -
    kind: "message-v1"
    backtrace:
      - "D:/vcpkg-2026/downloads/tools/cmake-4.4.0-windows/cmake-4.4.0-windows-x86_64/share/cmake-4.4/Modules/CMakeDetermineSystem.cmake:218 (message)"
      - "CMakeLists.txt:3 (project)"
    message: |
      The system is: Windows - 10.0.26200 - AMD64
  -
    kind: "find-v1"
    backtrace:
      - "D:/vcpkg-2026/downloads/tools/cmake-4.4.0-windows/cmake-4.4.0-windows-x86_64/share/cmake-4.4/Modules/CMakeDetermineCompiler.cmake:63 (find_program)"
      - "D:/vcpkg-2026/downloads/tools/cmake-4.4.0-windows/cmake-4.4.0-windows-x86_64/share/cmake-4.4/Modules/CMakeDetermineCCompiler.cmake:64 (_cmake_find_compiler)"
      - "CMakeLists.txt:3 (project)"
    mode: "program"
    variable: "CMAKE_C_COMPILER"
    description: "C compiler"
    settings:
      SearchFramework: "LAST"
      SearchAppBundle: "LAST"
      CMAKE_FIND_USE_CMAKE_PATH: false
      CMAKE_FIND_USE_CMAKE_ENVIRONMENT_PATH: false
      CMAKE_FIND_USE_SYSTEM_ENVIRONMENT_PATH: true
      CMAKE_FIND_USE_CMAKE_SYSTEM_PATH: false
      CMAKE_FIND_USE_INSTALL_PREFIX: true
    names:
      - "cc"
      - "gcc"
      - "cl"
      - "bcc"
      - "xlc"
      - "icx"
      - "clang"
    candidate_directories:
      - "D:/vcpkg-2026/installed/x64-windows/software/VisualStdio26/VC/Tools/MSVC/14.51.36231/bin/Hostx64/x64/"
      - "D:/vcpkg-2026/installed/x64-windows/software/VisualStdio26/Common7/IDE/VC/vcpackages/"
      - "D:/vcpkg-2026/installed/x64-windows/software/VisualStdio26/Common7/IDE/CommonExtensions/Microsoft/TestWindow/"
      - "D:/vcpkg-2026/installed/x64-windows/software/VisualStdio26/Common7/IDE/CommonExtensions/Microsoft/TeamFoundation/Team Explorer/"
      - "D:/vcpkg-2026/installed/x64-windows/software/VisualStdio26/MSBuild/Current/Bin/Roslyn/"
      - "D:/vcpkg-2026/installed/x64-windows/Program Files (x86)/Microsoft SDKs/Windows/v10.0A/bin/NETFX 4.8 Tools/x64/"
      - "D:/vcpkg-2026/installed/x64-windows/Program Files (x86)/HTML Help Workshop/"
      - "D:/vcpkg-2026/installed/x64-windows/software/VisualStdio26/Common7/IDE/CommonExtensions/Microsoft/FSharp/Tools/"
      - "D:/vcpkg-2026/installed/x64-windows/software/VisualStdio26/Team Tools/DiagnosticsHub/Collector/"
      - "D:/vcpkg-2026/installed/x64-windows/software/VisualStdio26/Common7/IDE/Extensions/Microsoft/CodeCoverage.Console/"
      - "D:/vcpkg-2026/installed/x64-windows/Windows Kits/10/bin/10.0.26100.0/x64/"
      - "D:/vcpkg-2026/installed/x64-windows/Windows Kits/10/bin/x64/"
      - "D:/vcpkg-2026/installed/x64-windows/software/VisualStdio26/MSBuild/Current/Bin/amd64/"
      - "D:/vcpkg-2026/installed/x64-windows/Windows/Microsoft.NET/Framework64/v4.0.30319/"
      - "D:/vcpkg-2026/installed/x64-windows/software/VisualStdio26/Common7/IDE/"
      - "D:/vcpkg-2026/installed/x64-windows/software/VisualStdio26/Common7/Tools/"
      - "D:/vcpkg-2026/installed/x64-windows/vcpkg-2026/downloads/tools/powershell-core-7.6.3-windows/"
      - "D:/vcpkg-2026/installed/x64-windows/Windows/System32/"
      - "D:/vcpkg-2026/installed/x64-windows/Windows/"
      - "D:/vcpkg-2026/installed/x64-windows/Windows/System32/wbem/"
      - "D:/vcpkg-2026/installed/x64-windows/Windows/System32/WindowsPowerShell/v1.0/"
      - "D:/vcpkg-2026/installed/x64-windows/Windows/System32/OpenSSH/"
      - "D:/vcpkg-2026/installed/x64-windows/software/VisualStdio26/Common7/IDE/CommonExtensions/Microsoft/CMake/CMake/bin/"
      - "D:/vcpkg-2026/installed/x64-windows/software/VisualStdio26/Common7/IDE/CommonExtensions/Microsoft/CMake/Ninja/"
      - "D:/vcpkg-2026/installed/x64-windows/software/VisualStdio26/Common7/IDE/VC/Linux/bin/ConnectionManagerExe/"
      - "D:/vcpkg-2026/installed/x64-windows/software/VisualStdio26/VC/vcpkg/"
      - "D:/vcpkg-2026/installed/x64-windows/debug/software/VisualStdio26/VC/Tools/MSVC/14.51.36231/bin/Hostx64/x64/"
      - "D:/vcpkg-2026/installed/x64-windows/debug/software/VisualStdio26/Common7/IDE/VC/vcpackages/"
      - "D:/vcpkg-2026/installed/x64-windows/debug/software/VisualStdio26/Common7/IDE/CommonExtensions/Microsoft/TestWindow/"
...
Skipped 3449 lines
...
        - "C:\\Program Files (x86)\\Microsoft SDKs\\Windows\\v10.0A\\bin\\NETFX 4.8 Tools\\x64\\"
        - "C:\\Program Files (x86)\\HTML Help Workshop"
        - "D:\\software\\VisualStdio26\\Common7\\IDE\\CommonExtensions\\Microsoft\\FSharp\\Tools"
        - "D:\\software\\VisualStdio26\\Team Tools\\DiagnosticsHub\\Collector"
        - "D:\\software\\VisualStdio26\\Common7\\IDE\\Extensions\\Microsoft\\CodeCoverage.Console"
        - "D:\\Windows Kits\\10\\bin\\10.0.26100.0\\\\x64"
        - "D:\\Windows Kits\\10\\bin\\\\x64"
        - "D:\\software\\VisualStdio26\\\\MSBuild\\Current\\Bin\\amd64"
        - "C:\\Windows\\Microsoft.NET\\Framework64\\v4.0.30319"
        - "D:\\software\\VisualStdio26\\Common7\\IDE\\"
        - "D:\\software\\VisualStdio26\\Common7\\Tools\\"
        - "D:\\vcpkg-2026\\downloads\\tools\\powershell-core-7.6.3-windows"
        - "C:\\Windows\\system32"
        - "C:\\Windows"
        - "C:\\Windows\\system32\\Wbem"
        - "C:\\Windows\\system32\\WindowsPowerShell\\v1.0\\"
        - "C:\\Windows\\system32\\OpenSSH\\"
        - "D:\\software\\VisualStdio26\\Common7\\IDE\\CommonExtensions\\Microsoft\\CMake\\CMake\\bin"
        - "D:\\software\\VisualStdio26\\Common7\\IDE\\CommonExtensions\\Microsoft\\CMake\\Ninja"
        - "D:\\software\\VisualStdio26\\Common7\\IDE\\VC\\Linux\\bin\\ConnectionManagerExe"
        - "D:\\software\\VisualStdio26\\VC\\vcpkg"
        - "D:\\software\\VisualStdio26\\Common7\\IDE\\CommonExtensions\\Microsoft\\CMake\\Ninja"
      CMAKE_INSTALL_PREFIX: "D:/vcpkg-2026/packages/glfw3_x64-windows"
      CMAKE_SYSTEM_PREFIX_PATH:
        - "C:/Program Files"
        - "C:/Program Files (x86)"
        - "D:/vcpkg-2026/downloads/tools/cmake-4.4.0-windows/cmake-4.4.0-windows-x86_64"
        - "D:/vcpkg-2026/packages/glfw3_x64-windows"
      CMAKE_FIND_ROOT_PATH: "D:/vcpkg-2026/installed/x64-windows;D:/vcpkg-2026/installed/x64-windows/debug"
  -
    kind: "try_compile-v1"
    backtrace:
      - "D:/vcpkg-2026/downloads/tools/cmake-4.4.0-windows/cmake-4.4.0-windows-x86_64/share/cmake-4.4/Modules/CMakeDetermineCompilerABI.cmake:123 (try_compile)"
      - "D:/vcpkg-2026/downloads/tools/cmake-4.4.0-windows/cmake-4.4.0-windows-x86_64/share/cmake-4.4/Modules/CMakeTestCCompiler.cmake:26 (CMAKE_DETERMINE_COMPILER_ABI)"
      - "CMakeLists.txt:3 (project)"
    checks:
      - "Detecting C compiler ABI info"
    directories:
      source: "D:/vcpkg-2026/buildtrees/glfw3/x64-windows-rel/CMakeFiles/CMakeScratch/TryCompile-4tawps"
      binary: "D:/vcpkg-2026/buildtrees/glfw3/x64-windows-rel/CMakeFiles/CMakeScratch/TryCompile-4tawps"
    cmakeVariables:
      CMAKE_C_FLAGS: " /nologo /DWIN32 /D_WINDOWS /utf-8 /MP "
      CMAKE_C_FLAGS_DEBUG: "/MDd /Z7 /Ob0 /Od /RTC1 "
      CMAKE_EXE_LINKER_FLAGS: "/machine:x64"
      CMAKE_MSVC_DEBUG_INFORMATION_FORMAT: ""
      CMAKE_MSVC_RUNTIME_LIBRARY: "MultiThreaded$<$<CONFIG:Debug>:Debug>$<$<STREQUAL:dynamic,dynamic>:DLL>"
      VCPKG_CHAINLOAD_TOOLCHAIN_FILE: "D:/vcpkg-2026/scripts/toolchains/windows.cmake"
      VCPKG_CRT_LINKAGE: "dynamic"
      VCPKG_CXX_FLAGS: ""
      VCPKG_CXX_FLAGS_DEBUG: ""
      VCPKG_CXX_FLAGS_RELEASE: ""
      VCPKG_C_FLAGS: ""
      VCPKG_C_FLAGS_DEBUG: ""
      VCPKG_C_FLAGS_RELEASE: ""
      VCPKG_INSTALLED_DIR: "D:/vcpkg-2026/installed"
      VCPKG_LINKER_FLAGS: ""
      VCPKG_LINKER_FLAGS_DEBUG: ""
      VCPKG_LINKER_FLAGS_RELEASE: ""
      VCPKG_PLATFORM_TOOLSET: "v145"
      VCPKG_PREFER_SYSTEM_LIBS: "OFF"
      VCPKG_SET_CHARSET_FLAG: "ON"
      VCPKG_TARGET_ARCHITECTURE: "x64"
      VCPKG_TARGET_TRIPLET: "x64-windows"
      Z_VCPKG_ROOT_DIR: "D:/vcpkg-2026"
    buildResult:
      variable: "CMAKE_C_ABI_COMPILED"
      cached: false
      stdout: |
        Change Dir: 'D:/vcpkg-2026/buildtrees/glfw3/x64-windows-rel/CMakeFiles/CMakeScratch/TryCompile-4tawps'
        
        Run Build Command(s): D:\\software\\VisualStdio26\\Common7\\IDE\\CommonExtensions\\Microsoft\\CMake\\Ninja\\ninja.exe -v cmTC_c1334
        [1/2] D:\\software\\VisualStdio26\\VC\\Tools\\MSVC\\14.51.36231\\bin\\Hostx64\\x64\\cl.exe  /nologo -D_MBCS  /nologo /DWIN32 /D_WINDOWS /utf-8 /MP   /MDd /Z7 /Ob0 /Od /RTC1  -MDd /showIncludes /FoCMakeFiles\\cmTC_c1334.dir\\CMakeCCompilerABI.c.obj /FdCMakeFiles\\cmTC_c1334.dir\\ /FS -c D:\\vcpkg-2026\\downloads\\tools\\cmake-4.4.0-windows\\cmake-4.4.0-windows-x86_64\\share\\cmake-4.4\\Modules\\CMakeCCompilerABI.c
        FAILED: [code=2] CMakeFiles/cmTC_c1334.dir/CMakeCCompilerABI.c.obj 
        D:\\software\\VisualStdio26\\VC\\Tools\\MSVC\\14.51.36231\\bin\\Hostx64\\x64\\cl.exe  /nologo -D_MBCS  /nologo /DWIN32 /D_WINDOWS /utf-8 /MP   /MDd /Z7 /Ob0 /Od /RTC1  -MDd /showIncludes /FoCMakeFiles\\cmTC_c1334.dir\\CMakeCCompilerABI.c.obj /FdCMakeFiles\\cmTC_c1334.dir\\ /FS -c D:\\vcpkg-2026\\downloads\\tools\\cmake-4.4.0-windows\\cmake-4.4.0-windows-x86_64\\share\\cmake-4.4\\Modules\\CMakeCCompilerABI.c
        cl: 命令行 error D8050 :无法执行“D:\\software\\VisualStdio26\\VC\\Tools\\MSVC\\14.51.36231\\bin\\Hostx64\\x64\\c1.dll”: 未能将命令行放入调试记录中
        ninja: build stopped: subcommand failed.
        
      exitCode: 2
  -
    kind: "try_compile-v1"
    backtrace:
      - "D:/vcpkg-2026/downloads/tools/cmake-4.4.0-windows/cmake-4.4.0-windows-x86_64/share/cmake-4.4/Modules/CMakeTestCCompiler.cmake:56 (try_compile)"
      - "CMakeLists.txt:3 (project)"
    checks:
      - "Check for working C compiler: D:/software/VisualStdio26/VC/Tools/MSVC/14.51.36231/bin/Hostx64/x64/cl.exe"
    directories:
      source: "D:/vcpkg-2026/buildtrees/glfw3/x64-windows-rel/CMakeFiles/CMakeScratch/TryCompile-vl6c1g"
      binary: "D:/vcpkg-2026/buildtrees/glfw3/x64-windows-rel/CMakeFiles/CMakeScratch/TryCompile-vl6c1g"
    cmakeVariables:
      CMAKE_C_FLAGS: " /nologo /DWIN32 /D_WINDOWS /utf-8 /MP "
      CMAKE_C_FLAGS_DEBUG: "/MDd /Z7 /Ob0 /Od /RTC1 "
      CMAKE_EXE_LINKER_FLAGS: "/machine:x64"
      CMAKE_MSVC_DEBUG_INFORMATION_FORMAT: ""
      CMAKE_MSVC_RUNTIME_LIBRARY: "MultiThreaded$<$<CONFIG:Debug>:Debug>$<$<STREQUAL:dynamic,dynamic>:DLL>"
      VCPKG_CHAINLOAD_TOOLCHAIN_FILE: "D:/vcpkg-2026/scripts/toolchains/windows.cmake"
      VCPKG_CRT_LINKAGE: "dynamic"
      VCPKG_CXX_FLAGS: ""
      VCPKG_CXX_FLAGS_DEBUG: ""
      VCPKG_CXX_FLAGS_RELEASE: ""
      VCPKG_C_FLAGS: ""
      VCPKG_C_FLAGS_DEBUG: ""
      VCPKG_C_FLAGS_RELEASE: ""
      VCPKG_INSTALLED_DIR: "D:/vcpkg-2026/installed"
      VCPKG_LINKER_FLAGS: ""
      VCPKG_LINKER_FLAGS_DEBUG: ""
      VCPKG_LINKER_FLAGS_RELEASE: ""
      VCPKG_PLATFORM_TOOLSET: "v145"
      VCPKG_PREFER_SYSTEM_LIBS: "OFF"
      VCPKG_SET_CHARSET_FLAG: "ON"
      VCPKG_TARGET_ARCHITECTURE: "x64"
      VCPKG_TARGET_TRIPLET: "x64-windows"
      Z_VCPKG_ROOT_DIR: "D:/vcpkg-2026"
    buildResult:
      variable: "CMAKE_C_COMPILER_WORKS"
      cached: false
      stdout: |
        Change Dir: 'D:/vcpkg-2026/buildtrees/glfw3/x64-windows-rel/CMakeFiles/CMakeScratch/TryCompile-vl6c1g'
        
        Run Build Command(s): D:\\software\\VisualStdio26\\Common7\\IDE\\CommonExtensions\\Microsoft\\CMake\\Ninja\\ninja.exe -v cmTC_2ae44
        [1/2] D:\\software\\VisualStdio26\\VC\\Tools\\MSVC\\14.51.36231\\bin\\Hostx64\\x64\\cl.exe  /nologo -D_MBCS  /nologo /DWIN32 /D_WINDOWS /utf-8 /MP   /MDd /Z7 /Ob0 /Od /RTC1  -MDd /showIncludes /FoCMakeFiles\\cmTC_2ae44.dir\\testCCompiler.c.obj /FdCMakeFiles\\cmTC_2ae44.dir\\ /FS -c D:\\vcpkg-2026\\buildtrees\\glfw3\\x64-windows-rel\\CMakeFiles\\CMakeScratch\\TryCompile-vl6c1g\\testCCompiler.c
        FAILED: [code=2] CMakeFiles/cmTC_2ae44.dir/testCCompiler.c.obj 
        D:\\software\\VisualStdio26\\VC\\Tools\\MSVC\\14.51.36231\\bin\\Hostx64\\x64\\cl.exe  /nologo -D_MBCS  /nologo /DWIN32 /D_WINDOWS /utf-8 /MP   /MDd /Z7 /Ob0 /Od /RTC1  -MDd /showIncludes /FoCMakeFiles\\cmTC_2ae44.dir\\testCCompiler.c.obj /FdCMakeFiles\\cmTC_2ae44.dir\\ /FS -c D:\\vcpkg-2026\\buildtrees\\glfw3\\x64-windows-rel\\CMakeFiles\\CMakeScratch\\TryCompile-vl6c1g\\testCCompiler.c
        cl: 命令行 error D8050 :无法执行“D:\\software\\VisualStdio26\\VC\\Tools\\MSVC\\14.51.36231\\bin\\Hostx64\\x64\\c1.dll”: 未能将命令行放入调试记录中
        ninja: build stopped: subcommand failed.
        
      exitCode: 2
...
```
</details>

<details><summary>D:\vcpkg-2026\buildtrees\glfw3\config-x64-windows-dbg-CMakeConfigureLog.yaml.log</summary>

```

---
events:
  -
    kind: "message-v1"
    backtrace:
      - "D:/vcpkg-2026/downloads/tools/cmake-4.4.0-windows/cmake-4.4.0-windows-x86_64/share/cmake-4.4/Modules/CMakeDetermineSystem.cmake:218 (message)"
      - "CMakeLists.txt:3 (project)"
    message: |
      The system is: Windows - 10.0.26200 - AMD64
  -
    kind: "find-v1"
    backtrace:
      - "D:/vcpkg-2026/downloads/tools/cmake-4.4.0-windows/cmake-4.4.0-windows-x86_64/share/cmake-4.4/Modules/CMakeDetermineCompiler.cmake:63 (find_program)"
      - "D:/vcpkg-2026/downloads/tools/cmake-4.4.0-windows/cmake-4.4.0-windows-x86_64/share/cmake-4.4/Modules/CMakeDetermineCCompiler.cmake:64 (_cmake_find_compiler)"
      - "CMakeLists.txt:3 (project)"
    mode: "program"
    variable: "CMAKE_C_COMPILER"
    description: "C compiler"
    settings:
      SearchFramework: "LAST"
      SearchAppBundle: "LAST"
      CMAKE_FIND_USE_CMAKE_PATH: false
      CMAKE_FIND_USE_CMAKE_ENVIRONMENT_PATH: false
      CMAKE_FIND_USE_SYSTEM_ENVIRONMENT_PATH: true
      CMAKE_FIND_USE_CMAKE_SYSTEM_PATH: false
      CMAKE_FIND_USE_INSTALL_PREFIX: true
    names:
      - "cc"
      - "gcc"
      - "cl"
      - "bcc"
      - "xlc"
      - "icx"
      - "clang"
    candidate_directories:
      - "D:/vcpkg-2026/installed/x64-windows/debug/software/VisualStdio26/VC/Tools/MSVC/14.51.36231/bin/Hostx64/x64/"
      - "D:/vcpkg-2026/installed/x64-windows/debug/software/VisualStdio26/Common7/IDE/VC/vcpackages/"
      - "D:/vcpkg-2026/installed/x64-windows/debug/software/VisualStdio26/Common7/IDE/CommonExtensions/Microsoft/TestWindow/"
      - "D:/vcpkg-2026/installed/x64-windows/debug/software/VisualStdio26/Common7/IDE/CommonExtensions/Microsoft/TeamFoundation/Team Explorer/"
      - "D:/vcpkg-2026/installed/x64-windows/debug/software/VisualStdio26/MSBuild/Current/Bin/Roslyn/"
      - "D:/vcpkg-2026/installed/x64-windows/debug/Program Files (x86)/Microsoft SDKs/Windows/v10.0A/bin/NETFX 4.8 Tools/x64/"
      - "D:/vcpkg-2026/installed/x64-windows/debug/Program Files (x86)/HTML Help Workshop/"
      - "D:/vcpkg-2026/installed/x64-windows/debug/software/VisualStdio26/Common7/IDE/CommonExtensions/Microsoft/FSharp/Tools/"
      - "D:/vcpkg-2026/installed/x64-windows/debug/software/VisualStdio26/Team Tools/DiagnosticsHub/Collector/"
      - "D:/vcpkg-2026/installed/x64-windows/debug/software/VisualStdio26/Common7/IDE/Extensions/Microsoft/CodeCoverage.Console/"
      - "D:/vcpkg-2026/installed/x64-windows/debug/Windows Kits/10/bin/10.0.26100.0/x64/"
      - "D:/vcpkg-2026/installed/x64-windows/debug/Windows Kits/10/bin/x64/"
      - "D:/vcpkg-2026/installed/x64-windows/debug/software/VisualStdio26/MSBuild/Current/Bin/amd64/"
      - "D:/vcpkg-2026/installed/x64-windows/debug/Windows/Microsoft.NET/Framework64/v4.0.30319/"
      - "D:/vcpkg-2026/installed/x64-windows/debug/software/VisualStdio26/Common7/IDE/"
      - "D:/vcpkg-2026/installed/x64-windows/debug/software/VisualStdio26/Common7/Tools/"
      - "D:/vcpkg-2026/installed/x64-windows/debug/vcpkg-2026/downloads/tools/powershell-core-7.6.3-windows/"
      - "D:/vcpkg-2026/installed/x64-windows/debug/Windows/System32/"
      - "D:/vcpkg-2026/installed/x64-windows/debug/Windows/"
      - "D:/vcpkg-2026/installed/x64-windows/debug/Windows/System32/wbem/"
      - "D:/vcpkg-2026/installed/x64-windows/debug/Windows/System32/WindowsPowerShell/v1.0/"
      - "D:/vcpkg-2026/installed/x64-windows/debug/Windows/System32/OpenSSH/"
      - "D:/vcpkg-2026/installed/x64-windows/debug/software/VisualStdio26/Common7/IDE/CommonExtensions/Microsoft/CMake/CMake/bin/"
      - "D:/vcpkg-2026/installed/x64-windows/debug/software/VisualStdio26/Common7/IDE/CommonExtensions/Microsoft/CMake/Ninja/"
      - "D:/vcpkg-2026/installed/x64-windows/debug/software/VisualStdio26/Common7/IDE/VC/Linux/bin/ConnectionManagerExe/"
      - "D:/vcpkg-2026/installed/x64-windows/debug/software/VisualStdio26/VC/vcpkg/"
      - "D:/vcpkg-2026/installed/x64-windows/software/VisualStdio26/VC/Tools/MSVC/14.51.36231/bin/Hostx64/x64/"
      - "D:/vcpkg-2026/installed/x64-windows/software/VisualStdio26/Common7/IDE/VC/vcpackages/"
...
Skipped 3450 lines
...
        - "C:\\Program Files (x86)\\Microsoft SDKs\\Windows\\v10.0A\\bin\\NETFX 4.8 Tools\\x64\\"
        - "C:\\Program Files (x86)\\HTML Help Workshop"
        - "D:\\software\\VisualStdio26\\Common7\\IDE\\CommonExtensions\\Microsoft\\FSharp\\Tools"
        - "D:\\software\\VisualStdio26\\Team Tools\\DiagnosticsHub\\Collector"
        - "D:\\software\\VisualStdio26\\Common7\\IDE\\Extensions\\Microsoft\\CodeCoverage.Console"
        - "D:\\Windows Kits\\10\\bin\\10.0.26100.0\\\\x64"
        - "D:\\Windows Kits\\10\\bin\\\\x64"
        - "D:\\software\\VisualStdio26\\\\MSBuild\\Current\\Bin\\amd64"
        - "C:\\Windows\\Microsoft.NET\\Framework64\\v4.0.30319"
        - "D:\\software\\VisualStdio26\\Common7\\IDE\\"
        - "D:\\software\\VisualStdio26\\Common7\\Tools\\"
        - "D:\\vcpkg-2026\\downloads\\tools\\powershell-core-7.6.3-windows"
        - "C:\\Windows\\system32"
        - "C:\\Windows"
        - "C:\\Windows\\system32\\Wbem"
        - "C:\\Windows\\system32\\WindowsPowerShell\\v1.0\\"
        - "C:\\Windows\\system32\\OpenSSH\\"
        - "D:\\software\\VisualStdio26\\Common7\\IDE\\CommonExtensions\\Microsoft\\CMake\\CMake\\bin"
        - "D:\\software\\VisualStdio26\\Common7\\IDE\\CommonExtensions\\Microsoft\\CMake\\Ninja"
        - "D:\\software\\VisualStdio26\\Common7\\IDE\\VC\\Linux\\bin\\ConnectionManagerExe"
        - "D:\\software\\VisualStdio26\\VC\\vcpkg"
        - "D:\\software\\VisualStdio26\\Common7\\IDE\\CommonExtensions\\Microsoft\\CMake\\Ninja"
      CMAKE_INSTALL_PREFIX: "D:/vcpkg-2026/packages/glfw3_x64-windows/debug"
      CMAKE_SYSTEM_PREFIX_PATH:
        - "C:/Program Files"
        - "C:/Program Files (x86)"
        - "D:/vcpkg-2026/downloads/tools/cmake-4.4.0-windows/cmake-4.4.0-windows-x86_64"
        - "D:/vcpkg-2026/packages/glfw3_x64-windows/debug"
      CMAKE_FIND_ROOT_PATH: "D:/vcpkg-2026/installed/x64-windows/debug;D:/vcpkg-2026/installed/x64-windows"
  -
    kind: "try_compile-v1"
    backtrace:
      - "D:/vcpkg-2026/downloads/tools/cmake-4.4.0-windows/cmake-4.4.0-windows-x86_64/share/cmake-4.4/Modules/CMakeDetermineCompilerABI.cmake:123 (try_compile)"
      - "D:/vcpkg-2026/downloads/tools/cmake-4.4.0-windows/cmake-4.4.0-windows-x86_64/share/cmake-4.4/Modules/CMakeTestCCompiler.cmake:26 (CMAKE_DETERMINE_COMPILER_ABI)"
      - "CMakeLists.txt:3 (project)"
    checks:
      - "Detecting C compiler ABI info"
    directories:
      source: "D:/vcpkg-2026/buildtrees/glfw3/x64-windows-dbg/CMakeFiles/CMakeScratch/TryCompile-ul3gbv"
      binary: "D:/vcpkg-2026/buildtrees/glfw3/x64-windows-dbg/CMakeFiles/CMakeScratch/TryCompile-ul3gbv"
    cmakeVariables:
      CMAKE_C_FLAGS: " /nologo /DWIN32 /D_WINDOWS /utf-8 /MP "
      CMAKE_C_FLAGS_DEBUG: "/MDd /Z7 /Ob0 /Od /RTC1 "
      CMAKE_EXE_LINKER_FLAGS: "/machine:x64"
      CMAKE_MSVC_DEBUG_INFORMATION_FORMAT: ""
      CMAKE_MSVC_RUNTIME_LIBRARY: "MultiThreaded$<$<CONFIG:Debug>:Debug>$<$<STREQUAL:dynamic,dynamic>:DLL>"
      VCPKG_CHAINLOAD_TOOLCHAIN_FILE: "D:/vcpkg-2026/scripts/toolchains/windows.cmake"
      VCPKG_CRT_LINKAGE: "dynamic"
      VCPKG_CXX_FLAGS: ""
      VCPKG_CXX_FLAGS_DEBUG: ""
      VCPKG_CXX_FLAGS_RELEASE: ""
      VCPKG_C_FLAGS: ""
      VCPKG_C_FLAGS_DEBUG: ""
      VCPKG_C_FLAGS_RELEASE: ""
      VCPKG_INSTALLED_DIR: "D:/vcpkg-2026/installed"
      VCPKG_LINKER_FLAGS: ""
      VCPKG_LINKER_FLAGS_DEBUG: ""
      VCPKG_LINKER_FLAGS_RELEASE: ""
      VCPKG_PLATFORM_TOOLSET: "v145"
      VCPKG_PREFER_SYSTEM_LIBS: "OFF"
      VCPKG_SET_CHARSET_FLAG: "ON"
      VCPKG_TARGET_ARCHITECTURE: "x64"
      VCPKG_TARGET_TRIPLET: "x64-windows"
      Z_VCPKG_ROOT_DIR: "D:/vcpkg-2026"
    buildResult:
      variable: "CMAKE_C_ABI_COMPILED"
      cached: false
      stdout: |
        Change Dir: 'D:/vcpkg-2026/buildtrees/glfw3/x64-windows-dbg/CMakeFiles/CMakeScratch/TryCompile-ul3gbv'
        
        Run Build Command(s): D:\\software\\VisualStdio26\\Common7\\IDE\\CommonExtensions\\Microsoft\\CMake\\Ninja\\ninja.exe -v cmTC_fc0db
        [1/2] D:\\software\\VisualStdio26\\VC\\Tools\\MSVC\\14.51.36231\\bin\\Hostx64\\x64\\cl.exe  /nologo -D_MBCS  /nologo /DWIN32 /D_WINDOWS /utf-8 /MP   /MDd /Z7 /Ob0 /Od /RTC1  -MDd /showIncludes /FoCMakeFiles\\cmTC_fc0db.dir\\CMakeCCompilerABI.c.obj /FdCMakeFiles\\cmTC_fc0db.dir\\ /FS -c D:\\vcpkg-2026\\downloads\\tools\\cmake-4.4.0-windows\\cmake-4.4.0-windows-x86_64\\share\\cmake-4.4\\Modules\\CMakeCCompilerABI.c
        FAILED: [code=2] CMakeFiles/cmTC_fc0db.dir/CMakeCCompilerABI.c.obj 
        D:\\software\\VisualStdio26\\VC\\Tools\\MSVC\\14.51.36231\\bin\\Hostx64\\x64\\cl.exe  /nologo -D_MBCS  /nologo /DWIN32 /D_WINDOWS /utf-8 /MP   /MDd /Z7 /Ob0 /Od /RTC1  -MDd /showIncludes /FoCMakeFiles\\cmTC_fc0db.dir\\CMakeCCompilerABI.c.obj /FdCMakeFiles\\cmTC_fc0db.dir\\ /FS -c D:\\vcpkg-2026\\downloads\\tools\\cmake-4.4.0-windows\\cmake-4.4.0-windows-x86_64\\share\\cmake-4.4\\Modules\\CMakeCCompilerABI.c
        cl: 命令行 error D8050 :无法执行“D:\\software\\VisualStdio26\\VC\\Tools\\MSVC\\14.51.36231\\bin\\Hostx64\\x64\\c1.dll”: 未能将命令行放入调试记录中
        ninja: build stopped: subcommand failed.
        
      exitCode: 2
  -
    kind: "try_compile-v1"
    backtrace:
      - "D:/vcpkg-2026/downloads/tools/cmake-4.4.0-windows/cmake-4.4.0-windows-x86_64/share/cmake-4.4/Modules/CMakeTestCCompiler.cmake:56 (try_compile)"
      - "CMakeLists.txt:3 (project)"
    checks:
      - "Check for working C compiler: D:/software/VisualStdio26/VC/Tools/MSVC/14.51.36231/bin/Hostx64/x64/cl.exe"
    directories:
      source: "D:/vcpkg-2026/buildtrees/glfw3/x64-windows-dbg/CMakeFiles/CMakeScratch/TryCompile-vigpi7"
      binary: "D:/vcpkg-2026/buildtrees/glfw3/x64-windows-dbg/CMakeFiles/CMakeScratch/TryCompile-vigpi7"
    cmakeVariables:
      CMAKE_C_FLAGS: " /nologo /DWIN32 /D_WINDOWS /utf-8 /MP "
      CMAKE_C_FLAGS_DEBUG: "/MDd /Z7 /Ob0 /Od /RTC1 "
      CMAKE_EXE_LINKER_FLAGS: "/machine:x64"
      CMAKE_MSVC_DEBUG_INFORMATION_FORMAT: ""
      CMAKE_MSVC_RUNTIME_LIBRARY: "MultiThreaded$<$<CONFIG:Debug>:Debug>$<$<STREQUAL:dynamic,dynamic>:DLL>"
      VCPKG_CHAINLOAD_TOOLCHAIN_FILE: "D:/vcpkg-2026/scripts/toolchains/windows.cmake"
      VCPKG_CRT_LINKAGE: "dynamic"
      VCPKG_CXX_FLAGS: ""
      VCPKG_CXX_FLAGS_DEBUG: ""
      VCPKG_CXX_FLAGS_RELEASE: ""
      VCPKG_C_FLAGS: ""
      VCPKG_C_FLAGS_DEBUG: ""
      VCPKG_C_FLAGS_RELEASE: ""
      VCPKG_INSTALLED_DIR: "D:/vcpkg-2026/installed"
      VCPKG_LINKER_FLAGS: ""
      VCPKG_LINKER_FLAGS_DEBUG: ""
      VCPKG_LINKER_FLAGS_RELEASE: ""
      VCPKG_PLATFORM_TOOLSET: "v145"
      VCPKG_PREFER_SYSTEM_LIBS: "OFF"
      VCPKG_SET_CHARSET_FLAG: "ON"
      VCPKG_TARGET_ARCHITECTURE: "x64"
      VCPKG_TARGET_TRIPLET: "x64-windows"
      Z_VCPKG_ROOT_DIR: "D:/vcpkg-2026"
    buildResult:
      variable: "CMAKE_C_COMPILER_WORKS"
      cached: false
      stdout: |
        Change Dir: 'D:/vcpkg-2026/buildtrees/glfw3/x64-windows-dbg/CMakeFiles/CMakeScratch/TryCompile-vigpi7'
        
        Run Build Command(s): D:\\software\\VisualStdio26\\Common7\\IDE\\CommonExtensions\\Microsoft\\CMake\\Ninja\\ninja.exe -v cmTC_e1d35
        [1/2] D:\\software\\VisualStdio26\\VC\\Tools\\MSVC\\14.51.36231\\bin\\Hostx64\\x64\\cl.exe  /nologo -D_MBCS  /nologo /DWIN32 /D_WINDOWS /utf-8 /MP   /MDd /Z7 /Ob0 /Od /RTC1  -MDd /showIncludes /FoCMakeFiles\\cmTC_e1d35.dir\\testCCompiler.c.obj /FdCMakeFiles\\cmTC_e1d35.dir\\ /FS -c D:\\vcpkg-2026\\buildtrees\\glfw3\\x64-windows-dbg\\CMakeFiles\\CMakeScratch\\TryCompile-vigpi7\\testCCompiler.c
        FAILED: [code=2] CMakeFiles/cmTC_e1d35.dir/testCCompiler.c.obj 
        D:\\software\\VisualStdio26\\VC\\Tools\\MSVC\\14.51.36231\\bin\\Hostx64\\x64\\cl.exe  /nologo -D_MBCS  /nologo /DWIN32 /D_WINDOWS /utf-8 /MP   /MDd /Z7 /Ob0 /Od /RTC1  -MDd /showIncludes /FoCMakeFiles\\cmTC_e1d35.dir\\testCCompiler.c.obj /FdCMakeFiles\\cmTC_e1d35.dir\\ /FS -c D:\\vcpkg-2026\\buildtrees\\glfw3\\x64-windows-dbg\\CMakeFiles\\CMakeScratch\\TryCompile-vigpi7\\testCCompiler.c
        cl: 命令行 error D8050 :无法执行“D:\\software\\VisualStdio26\\VC\\Tools\\MSVC\\14.51.36231\\bin\\Hostx64\\x64\\c1.dll”: 未能将命令行放入调试记录中
        ninja: build stopped: subcommand failed.
        
      exitCode: 2
...
```
</details>

