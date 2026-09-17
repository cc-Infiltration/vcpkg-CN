macro(z_vcpkg_determine_autotools_host_cpu out_var)
    # TODO: 主机系统处理器架构可能与主机三元组目标架构不同
    if(DEFINED ENV{PROCESSOR_ARCHITEW6432})
        set(host_arch $ENV{PROCESSOR_ARCHITEW6432})
    elseif(DEFINED ENV{PROCESSOR_ARCHITECTURE})
        set(host_arch $ENV{PROCESSOR_ARCHITECTURE})
    else()
        set(host_arch "${VCPKG_DETECTED_CMAKE_HOST_SYSTEM_PROCESSOR}")
    endif()
    if(host_arch MATCHES "(amd|AMD)64")
        set(${out_var} x86_64)
    elseif(host_arch MATCHES "(x|X)86")
        set(${out_var} i686)
    elseif(host_arch MATCHES "^(ARM|arm)64$")
        set(${out_var} aarch64)
    elseif(host_arch MATCHES "^(ARM|arm)$")
        set(${out_var} arm)
    else()
        message(FATAL_ERROR "在 z_vcpkg_determine_autotools_host_cpu 中不支持的主机架构 ${host_arch}！" )
    endif()
    unset(host_arch)
endmacro()

macro(z_vcpkg_determine_autotools_target_cpu out_var)
    if(VCPKG_TARGET_ARCHITECTURE MATCHES "(x|X)64")
        set(${out_var} x86_64)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "(x|X)86")
        set(${out_var} i686)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "^(ARM|arm)64$")
        set(${out_var} aarch64)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "^(ARM|arm)$")
        set(${out_var} arm)
    else()
        message(FATAL_ERROR "在 z_vcpkg_determine_autotools_target_cpu 中不支持的 VCPKG_TARGET_ARCHITECTURE 架构 ${VCPKG_TARGET_ARCHITECTURE}！" )
    endif()
endmacro()

macro(z_vcpkg_set_arch_mac out_var value)
    # 更好地匹配 config.guess 的架构行为
    # 参见: https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD
    if("${value}" MATCHES "^(ARM|arm)64$")
        set(${out_var} "aarch64")
    else()
        set(${out_var} "${value}")
    endif()
endmacro()

macro(z_vcpkg_determine_autotools_host_arch_mac out_var)
    z_vcpkg_set_arch_mac(${out_var} "${VCPKG_DETECTED_CMAKE_HOST_SYSTEM_PROCESSOR}")
endmacro()

macro(z_vcpkg_determine_autotools_target_arch_mac out_var)
    list(LENGTH VCPKG_OSX_ARCHITECTURES osx_archs_num)
    if(osx_archs_num EQUAL 0)
        z_vcpkg_set_arch_mac(${out_var} "${VCPKG_DETECTED_CMAKE_HOST_SYSTEM_PROCESSOR}")
    elseif(osx_archs_num GREATER_EQUAL 2)
        set(${out_var} "universal")
    else()
        z_vcpkg_set_arch_mac(${out_var} "${VCPKG_OSX_ARCHITECTURES}")
    endif()
    unset(osx_archs_num)
endmacro()

# 定义在 vcpkg_configure_make 和 vcpkg_build_make 中使用的变量：
# short_name_<CONFIG>:           给定构建类型的唯一缩写 (rel, dbg)
# path_suffix_<CONFIG>:          给定构建类型的安装路径后缀 ('', /debug)
# current_installed_dir_escaped: 转义了空格字符的 CURRENT_INSTALLED_DIR
# current_installed_dir_msys:    未转义空格但驱动器盘符已为 msys 转换的 CURRENT_INSTALLED_DIR
macro(z_vcpkg_configure_make_common_definitions)
    set(short_name_RELEASE "rel")
    set(short_name_DEBUG "dbg")

    set(path_suffix_RELEASE "")
    set(path_suffix_DEBUG "/debug")

    # 一些处理空格的 PATH 操作....一些工具仍会因此失败！
    # 特别是 libtool 的 install 命令无法正确安装到带空格的路径。
    string(REPLACE " " "\\ " current_installed_dir_escaped "${CURRENT_INSTALLED_DIR}")
    set(current_installed_dir_msys "${CURRENT_INSTALLED_DIR}")
    if(CMAKE_HOST_WIN32)
        string(REGEX REPLACE "^([a-zA-Z]):/" "/\\1/" current_installed_dir_msys "${current_installed_dir_msys}")
    endif()
endmacro()

# 初始化标志的已知变量和辅助变量
# - CPPFLAGS_<CONFIG>: C 和 CXX 共用的预处理器标志
# - CFLAGS_<CONFIG>
# - CXXFLAGS_<CONFIG>
# - LDFLAGS_<CONFIG>
# - ARFLAGS_<CONFIG>
# - LINK_ENV_${var_suffix}
# 前提条件: 已加载 VCPKG_DETECTED_CMAKE_... 变量
function(z_vcpkg_configure_make_process_flags var_suffix)
    # 需要 separate_arguments 来移除检测到的 cmake 变量的外层引号。
    # （例如 Android NDK 有 "--sysroot=..."）
    separate_arguments(CFLAGS NATIVE_COMMAND "Z_VCM_WRAP ${VCPKG_DETECTED_CMAKE_C_FLAGS_${var_suffix}} Z_VCM_WRAP")
    separate_arguments(CXXFLAGS NATIVE_COMMAND "Z_VCM_WRAP ${VCPKG_DETECTED_CMAKE_CXX_FLAGS_${var_suffix}} Z_VCM_WRAP")
    separate_arguments(LDFLAGS NATIVE_COMMAND "${VCPKG_DETECTED_CMAKE_SHARED_LINKER_FLAGS_${var_suffix}}")
    separate_arguments(ARFLAGS NATIVE_COMMAND "${VCPKG_DETECTED_CMAKE_STATIC_LINKER_FLAGS_${var_suffix}}")
    foreach(var IN ITEMS CFLAGS CXXFLAGS LDFLAGS ARFLAGS)
        vcpkg_list(APPEND z_vcm_all_flags ${${var}})
    endforeach()
    set(z_vcm_all_flags "${z_vcm_all_flags}" PARENT_SCOPE)

    # 从 CFLAGS 和 CXXFLAGS 中过滤出共用的 CPPFLAGS
    vcpkg_list(SET CPPFLAGS)
    vcpkg_list(SET pattern)
    foreach(arg IN LISTS CXXFLAGS)
        if(arg STREQUAL "Z_VCM_WRAP")
            continue()
        elseif(NOT pattern STREQUAL "")
            vcpkg_list(APPEND pattern "${arg}")
        elseif(arg MATCHES "^-(D|isystem).")
            vcpkg_list(SET pattern "${arg}")
        elseif(arg MATCHES "^-(D|isystem)\$")
            vcpkg_list(SET pattern "${arg}")
            continue()
        elseif(arg MATCHES "^-(-sysroot|-target|m?[Aa][Rr][Cc][Hh])=.")
            vcpkg_list(SET pattern "${arg}")
        elseif(arg MATCHES "^-(isysroot|m32|m64|m?[Aa][Rr][Cc][Hh]|target)\$")
            vcpkg_list(SET pattern "${arg}")
            continue()
        else()
            continue()
        endif()
        string(FIND "${CFLAGS}" ";${pattern};" index)
        if(NOT index STREQUAL "-1")
            vcpkg_list(APPEND CPPFLAGS ${pattern})
            string(REPLACE ";${pattern};" ";" CFLAGS "${CFLAGS}")
            string(REPLACE ";${pattern};" ";" CXXFLAGS "${CXXFLAGS}")
        endif()
        vcpkg_list(SET pattern)
    endforeach()
    vcpkg_list(SET pattern)
    foreach(arg IN LISTS CFLAGS)
        if(arg STREQUAL "Z_VCM_WRAP")
            continue()
        elseif(NOT pattern STREQUAL "")
            vcpkg_list(APPEND pattern "${arg}")
        elseif(arg MATCHES "^-(D|isystem)\$")
            vcpkg_list(SET pattern "${arg}")
            continue()
        elseif(arg MATCHES "^-(D|isystem).")
            vcpkg_list(SET pattern "${arg}")
        elseif(arg MATCHES "^-(-sysroot|-target|m?[Aa][Rr][Cc][Hh])=.")
            vcpkg_list(SET pattern "${arg}")
        elseif(arg MATCHES "^-(isysroot|m32|m64|m?[Aa][Rr][Cc][Hh]|target)\$")
            vcpkg_list(SET pattern "${arg}")
            continue()
        else()
            continue()
        endif()
        string(FIND "${CXXFLAGS}" ";${pattern};" index)
        if(NOT index STREQUAL "-1")
            vcpkg_list(APPEND CPPFLAGS ${pattern})
            string(REPLACE ";${pattern};" ";" CFLAGS "${CFLAGS}")
            string(REPLACE ";${pattern};" ";" CXXFLAGS "${CXXFLAGS}")
        endif()
        vcpkg_list(SET pattern)
    endforeach()

    # 移除起始/结束占位符
    foreach(list IN ITEMS CFLAGS CXXFLAGS)
        vcpkg_list(REMOVE_ITEM ${list} "Z_VCM_WRAP")
    endforeach()

    # libtool 尝试通过允许列表来过滤传递给链接阶段的 CFLAGS。
    # 此方法有缺陷，因为它无法传递 libtool 未知的
    # 但链接所需的标志（例如 -fsanitize=<x>）。
    # libtool 有 -R 选项，因此我们需要使用 -Xcompiler 来防止 -RTC。
    # 配置时可能会有大量未知的编译器选项警告
    # ；直接忽略它们。
    set(compiler_flag_escape "")
    if(VCPKG_DETECTED_CMAKE_C_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC" OR VCPKG_DETECTED_CMAKE_C_COMPILER_ID STREQUAL "MSVC")
        set(compiler_flag_escape "-Xcompiler ")
    endif()
    if(compiler_flag_escape)
        list(TRANSFORM CFLAGS PREPEND "${compiler_flag_escape}")
        list(TRANSFORM CXXFLAGS PREPEND "${compiler_flag_escape}")
    endif()

    # 可以使用未来的 VCPKG_DETECTED_CMAKE_LIBRARY_PATH_FLAG
    set(library_path_flag "-L")
    # 可以使用未来的 VCPKG_DETECTED_MSVC
    if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_DETECTED_CMAKE_LINKER MATCHES [[link\.exe$]])
        set(library_path_flag "-LIBPATH:")
    endif()
    set(linker_flag_escape "")
    if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_DETECTED_CMAKE_C_COMPILER MATCHES [[cl\.exe$]])
        # 被 libtool 移除
        set(linker_flag_escape "-Xlinker ")
        if(arg_USE_WRAPPERS)
            # 第1个和第3个被 libtool 移除，第2个被 wrapper 移除
            set(linker_flag_escape "-Xlinker -Xlinker -Xlinker ")
        endif()
        if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
            string(STRIP "$ENV{_LINK_} ${VCPKG_DETECTED_CMAKE_STATIC_LINKER_FLAGS_${var_suffix}}" LINK_ENV)
        else()
            string(STRIP "$ENV{_LINK_} ${VCPKG_DETECTED_CMAKE_SHARED_LINKER_FLAGS_${var_suffix}}" LINK_ENV)
        endif()
    endif()
    if(linker_flag_escape)
        list(TRANSFORM LDFLAGS PREPEND "${linker_flag_escape}")
    endif()
    if(EXISTS "${CURRENT_INSTALLED_DIR}${path_suffix_${var_suffix}}/lib/manual-link")
        vcpkg_list(PREPEND LDFLAGS "${linker_flag_escape}${library_path_flag}${current_installed_dir_escaped}${path_suffix_${var_suffix}}/lib/manual-link")
    endif()
    if(EXISTS "${CURRENT_INSTALLED_DIR}${path_suffix_${var_suffix}}/lib")
        vcpkg_list(PREPEND LDFLAGS "${linker_flag_escape}${library_path_flag}${current_installed_dir_escaped}${path_suffix_${var_suffix}}/lib")
    endif()

    if(ARFLAGS)
        # ARFLAGS 需要知道创建归档的命令（可能需要用户自定义？）
        # 或者通过 CMAKE_${lang}_ARCHIVE_CREATE 从 CMake 中提取？
        # 或者从 CMAKE_${lang}_${rule} 中提取，其中 rule 为 CREATE_SHARED_MODULE CREATE_SHARED_LIBRARY LINK_EXECUTABLE 之一
        vcpkg_list(PREPEND ARFLAGS "cr")
    endif()

    foreach(var IN ITEMS CPPFLAGS CFLAGS CXXFLAGS LDFLAGS ARFLAGS)
        list(JOIN ${var} " " string)
        set(${var}_${var_suffix} "${string}" PARENT_SCOPE)
    endforeach()
endfunction()

macro(z_vcpkg_append_to_configure_environment inoutstring var defaultval)
    # 允许在 Windows 上通过环境变量覆盖自定义三元组中的设置
    if(CMAKE_HOST_WIN32 AND DEFINED ENV{${var}})
        string(APPEND ${inoutstring} " ${var}='$ENV{${var}}'")
    else()
        string(APPEND ${inoutstring} " ${var}='${defaultval}'")
    endif()
endmacro()

function(vcpkg_configure_make)
    # 解析参数，使得 COMMAND 选项参数中的分号不会被擦除
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "AUTOCONFIG;SKIP_CONFIGURE;COPY_SOURCE;DISABLE_VERBOSE_FLAGS;NO_ADDITIONAL_PATHS;ADD_BIN_TO_PATH;NO_DEBUG;USE_WRAPPERS;NO_WRAPPERS;DETERMINE_BUILD_TRIPLET"
        "SOURCE_PATH;PROJECT_SUBPATH;PRERUN_SHELL;BUILD_TRIPLET"
        "OPTIONS;OPTIONS_DEBUG;OPTIONS_RELEASE;CONFIGURE_ENVIRONMENT_VARIABLES;CONFIG_DEPENDENT_ENVIRONMENT;ADDITIONAL_MSYS_PACKAGES"
    )

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "${CMAKE_CURRENT_FUNCTION} 被传递了多余的参数: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    if(arg_USE_WRAPPERS AND arg_NO_WRAPPERS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} 被传递了冲突的选项 USE_WRAPPERS 和 NO_WRAPPERS。请移除其中一个！")
    endif()

    z_vcpkg_get_cmake_vars(cmake_vars_file)
    debug_message("正在从以下位置包含 cmake 变量: ${cmake_vars_file}")
    include("${cmake_vars_file}")

    if(DEFINED VCPKG_MAKE_BUILD_TRIPLET)
        set(arg_BUILD_TRIPLET ${VCPKG_MAKE_BUILD_TRIPLET}) # 用于交叉编译的三元组覆盖
    endif()

    set(src_dir "${arg_SOURCE_PATH}/${arg_PROJECT_SUBPATH}")

    set(requires_autogen OFF) # 使用 autogen.sh
    set(requires_autoconfig OFF) # 使用 autotools 和 configure.ac
    if(EXISTS "${src_dir}/configure" AND EXISTS "${src_dir}/configure.ac" AND arg_AUTOCONFIG) # 移除 configure；重新运行 autoconf
        set(requires_autoconfig ON)
        file(REMOVE "${SRC_DIR}/configure") # 移除可能过时的 configure 脚本
    elseif(arg_SKIP_CONFIGURE)
        # 未请求任何操作
    elseif(EXISTS "${src_dir}/configure")
        # 正常运行；不需要 autoconf 或 autogen
    elseif(EXISTS "${src_dir}/configure.ac") # 运行 autoconfig
        set(requires_autoconfig ON)
        set(arg_AUTOCONFIG ON)
    elseif(EXISTS "${src_dir}/autogen.sh") # 运行 autogen
        set(requires_autogen ON)
    else()
        message(FATAL_ERROR "无法确定配置 make 的方法")
    endif()

    debug_message("requires_autogen:${requires_autogen}")
    debug_message("requires_autoconfig:${requires_autoconfig}")

    if(CMAKE_HOST_WIN32 AND VCPKG_DETECTED_CMAKE_C_COMPILER MATCHES "cl.exe") #仅适用于 Windows 的 (clang-)cl 和 lib
        if(arg_AUTOCONFIG)
            set(arg_USE_WRAPPERS ON)
        else()
            # 保留 portfile 中的设置。
            # 如果没有 autotools，我们假定使用自定义的 configure 脚本，它能正确处理 cl 和 lib。
            # 否则端口需要设置 CC|CXX|AR 可能还有 CPP。
        endif()
    else()
        set(arg_USE_WRAPPERS OFF)
    endif()
    if(arg_NO_WRAPPERS)
        set(arg_USE_WRAPPERS OFF)
    endif()

    # 备份环境变量
    # CCAS CC C CPP CXX FC FF GC LD LF LIBTOOL OBJC OBJCXX R UPC Y
    set(cm_FLAGS AR AS CCAS CC C CPP CXX FC FF GC LD LF LIBTOOL OBJC OBJXX R UPC Y RC)
    list(TRANSFORM cm_FLAGS APPEND "FLAGS")
    vcpkg_backup_env_variables(VARS ${cm_FLAGS})


    # FC Fortran 编译器 | FF Fortran 77 编译器
    # LDFLAGS -> 传递 -L 标志
    # LIBS -> 传递 -l 标志

    # 用于 gcc/linux
    vcpkg_backup_env_variables(VARS C_INCLUDE_PATH CPLUS_INCLUDE_PATH LIBRARY_PATH LD_LIBRARY_PATH)

    # 用于 cl
    vcpkg_backup_env_variables(VARS INCLUDE LIB LIBPATH)

    vcpkg_list(SET z_vcm_paths_with_spaces)
    if(CURRENT_PACKAGES_DIR MATCHES " ")
        vcpkg_list(APPEND z_vcm_paths_with_spaces "${CURRENT_PACKAGES_DIR}")
    endif()
    if(CURRENT_INSTALLED_DIR MATCHES " ")
        vcpkg_list(APPEND z_vcm_paths_with_spaces "${CURRENT_INSTALLED_DIR}")
    endif()
    if(z_vcm_paths_with_spaces)
        # 不必担心空格。工具可能会失败，我已经非常努力地尝试使其工作（至今未成功）！
        vcpkg_list(APPEND z_vcm_paths_with_spaces "请将路径移动到不含空格的位置！")
        list(JOIN z_vcm_paths_with_spaces "\n   " z_vcm_paths_with_spaces)
        message(STATUS "警告: 路径中包含空格可能会被 configure 错误处理:\n   ${z_vcm_paths_with_spaces}")
    endif()

    set(configure_env "V=1")

    # 建立 autotools 所需的 bash 环境。
    if(CMAKE_HOST_WIN32)
        list(APPEND msys_require_packages autoconf-wrapper automake-wrapper binutils libtool make pkgconf which)
        vcpkg_acquire_msys(MSYS_ROOT PACKAGES ${msys_require_packages} ${arg_ADDITIONAL_MSYS_PACKAGES})
        set(base_cmd "${MSYS_ROOT}/usr/bin/bash.exe" --noprofile --norc --debug)
        vcpkg_list(SET add_to_env)
        if(arg_USE_WRAPPERS AND VCPKG_TARGET_IS_WINDOWS)
            vcpkg_list(APPEND add_to_env "${SCRIPTS}/buildsystems/make_wrapper") # 其他所需的 wrapper 也位于此处
            vcpkg_list(APPEND add_to_env "${MSYS_ROOT}/usr/share/automake-1.16")
        endif()
        cmake_path(CONVERT "$ENV{PATH}" TO_CMAKE_PATH_LIST path_list NORMALIZE)
        cmake_path(CONVERT "$ENV{SystemRoot}" TO_CMAKE_PATH_LIST system_root NORMALIZE)
        cmake_path(CONVERT "$ENV{LOCALAPPDATA}" TO_CMAKE_PATH_LIST local_app_data NORMALIZE)
        file(REAL_PATH "${system_root}" system_root)

        message(DEBUG "path_list:${path_list}") # 仅为获取 --trace-expand 输出

        vcpkg_list(SET find_system_dirs
            "${system_root}/System32"
            "${system_root}/System32/"
            "${local_app_data}/Microsoft/WindowsApps"
            "${local_app_data}/Microsoft/WindowsApps/"
        )

        string(TOUPPER "${find_system_dirs}" find_system_dirs_upper)

        set(index 0)
        set(appending TRUE)
        foreach(item IN LISTS path_list)
            string(TOUPPER "${item}" item_upper)
            if(item_upper IN_LIST find_system_dirs_upper)
                set(appending FALSE)
                break()
            endif()
            math(EXPR index "${index} + 1")
        endforeach()

        if(appending)
            message(WARNING "在 PATH 变量中找不到系统目录！正在追加所需的 msys 路径！")
        endif()
        vcpkg_list(INSERT path_list "${index}" ${add_to_env} "${MSYS_ROOT}/usr/bin")

        cmake_path(CONVERT "${path_list}" TO_NATIVE_PATH_LIST native_path_list)
        set(ENV{PATH} "${native_path_list}")
    else()
        find_program(base_cmd bash REQUIRED)
    endif()

    # Apple 平台 - 交叉编译支持
    if(VCPKG_TARGET_IS_APPLE)
        if (requires_autoconfig AND NOT arg_BUILD_TRIPLET OR arg_DETERMINE_BUILD_TRIPLET)
            z_vcpkg_determine_autotools_host_arch_mac(BUILD_ARCH) # 构建所在的机器 => --build=
            z_vcpkg_determine_autotools_target_arch_mac(TARGET_ARCH)
            # --build: 构建所在的机器
            # --host: 为其构建的机器
            # --target: CC 将为其生成二进制文件的机器
            # https://stackoverflow.com/questions/21990021/how-to-determine-host-value-for-configure-when-using-cross-compiler
            # 仅适用于使用 autotools 的端口，因此我们可以假定它们遵循 build/target/host 的通用约定
            if(NOT "${TARGET_ARCH}" STREQUAL "${BUILD_ARCH}" OR NOT VCPKG_TARGET_IS_OSX) # 如果是原生构建，则不需要指定额外标志。
                set(arg_BUILD_TRIPLET "--host=${TARGET_ARCH}-apple-darwin") # （Host 激活交叉编译；此处给出的名称只是目标主机工具的前缀）
            endif()
            debug_message("使用的 make 三元组: ${arg_BUILD_TRIPLET}")
        endif()
    endif()

    # Linux / BSD / Solaris - 交叉编译支持
    if(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_BSD OR VCPKG_TARGET_IS_SOLARIS)
        if (requires_autoconfig AND NOT arg_BUILD_TRIPLET OR arg_DETERMINE_BUILD_TRIPLET)
            # 下面的正则表达式从结果 CMAKE_C_COMPILER 变量中提取前缀，例如 arm-linux-gnueabihf-gcc
            # 在通用 toolchains/linux.cmake 中设置
            # 这通过 --host 用作所有其他 bin 工具的前缀。
            # 直接通过 CC=arm-linux-gnueabihf-gcc 设置编译器不起作用，参见:
            # https://www.gnu.org/software/autoconf/manual/autoconf-2.65/html_node/Specifying-Target-Triplets.html
            if(VCPKG_DETECTED_CMAKE_C_COMPILER MATCHES "([^\/]*)-gcc$" AND CMAKE_MATCH_1)
                set(arg_BUILD_TRIPLET "--host=${CMAKE_MATCH_1}") # （Host 激活交叉编译；此处给出的名称只是目标主机工具的前缀）
            endif()
            debug_message("使用的 make 三元组: ${arg_BUILD_TRIPLET}")
        endif()
    endif()

    # 预处理 Windows 配置需求
    if (VCPKG_TARGET_IS_WINDOWS)
        if (arg_DETERMINE_BUILD_TRIPLET OR NOT arg_BUILD_TRIPLET)
            z_vcpkg_determine_autotools_host_cpu(BUILD_ARCH) # VCPKG_HOST => 构建所在的机器 => --build=
            z_vcpkg_determine_autotools_target_cpu(TARGET_ARCH)
            # --build: 构建所在的机器
            # --host: 为其构建的机器
            # --target: CC 将为其生成二进制文件的机器
            # https://stackoverflow.com/questions/21990021/how-to-determine-host-value-for-configure-when-using-cross-compiler
            # 仅适用于使用 autotools 的端口，因此我们可以假定它们遵循 build/target/host 的通用约定
            if(CMAKE_HOST_WIN32)
                # 确定时考虑主机三元组 --build
                if(NOT VCPKG_CROSSCOMPILING)
                    set(_win32_build_arch "${TARGET_ARCH}")
                else()
                    set(_win32_build_arch "${BUILD_ARCH}")
                endif()

                # 这是必需的，因为我们在 msys
                # shell 中运行，否则会被识别为 ${BUILD_ARCH}-pc-msys
                set(arg_BUILD_TRIPLET "--build=${_win32_build_arch}-pc-mingw32")
            endif()
            if(NOT TARGET_ARCH MATCHES "${BUILD_ARCH}" OR NOT CMAKE_HOST_WIN32) # 原生构建时不需要指定额外标志，不在 Windows 上时则不适用
                string(APPEND arg_BUILD_TRIPLET " --host=${TARGET_ARCH}-pc-mingw32") # （Host 激活交叉编译；此处给出的名称只是目标主机工具的前缀）
            endif()
            if(VCPKG_TARGET_IS_UWP AND NOT arg_BUILD_TRIPLET MATCHES "--host")
                # 需要与 --build 不同以启用交叉构建。
                string(APPEND arg_BUILD_TRIPLET " --host=${TARGET_ARCH}-unknown-mingw32")
            endif()
            debug_message("使用的 make 三元组: ${arg_BUILD_TRIPLET}")
        endif()

        # 由于空格问题移除完整文件路径，并将文件路径前置到 PATH 中（交叉编译工具默认不太可能在 PATH 中）
        set(progs VCPKG_DETECTED_CMAKE_C_COMPILER VCPKG_DETECTED_CMAKE_CXX_COMPILER VCPKG_DETECTED_CMAKE_AR
                  VCPKG_DETECTED_CMAKE_LINKER VCPKG_DETECTED_CMAKE_RANLIB VCPKG_DETECTED_CMAKE_OBJDUMP
                  VCPKG_DETECTED_CMAKE_STRIP VCPKG_DETECTED_CMAKE_NM VCPKG_DETECTED_CMAKE_DLLTOOL VCPKG_DETECTED_CMAKE_RC_COMPILER)
        foreach(prog IN LISTS progs)
            set(filepath "${${prog}}")
            if(filepath MATCHES " ")
                cmake_path(GET filepath FILENAME ${prog})
                find_program(z_vcm_prog_found NAMES "${${prog}}" PATHS ENV PATH NO_DEFAULT_PATH NO_CACHE)
                if(NOT z_vcm_prog_found STREQUAL filepath)
                    cmake_path(GET filepath PARENT_PATH dir)
                    vcpkg_add_to_path(PREPEND "${dir}")
                endif()
            endif()
        endforeach()
        if (arg_USE_WRAPPERS)
            z_vcpkg_append_to_configure_environment(configure_env CPP "compile ${VCPKG_DETECTED_CMAKE_C_COMPILER} -E")

            z_vcpkg_append_to_configure_environment(configure_env CC "compile ${VCPKG_DETECTED_CMAKE_C_COMPILER}")
            if(NOT arg_BUILD_TRIPLET MATCHES "--host")
                z_vcpkg_append_to_configure_environment(configure_env CC_FOR_BUILD "compile ${VCPKG_DETECTED_CMAKE_C_COMPILER}")
                z_vcpkg_append_to_configure_environment(configure_env CPP_FOR_BUILD "compile ${VCPKG_DETECTED_CMAKE_C_COMPILER} -E")
                z_vcpkg_append_to_configure_environment(configure_env CXX_FOR_BUILD "compile ${VCPKG_DETECTED_CMAKE_CXX_COMPILER}")
            else()
                # 用来让 configure 接受 CC_FOR_BUILD 的小技巧，但实际上 CC_FOR_BUILD 是被禁用的。
                z_vcpkg_append_to_configure_environment(configure_env CC_FOR_BUILD "touch a.out | touch conftest${VCPKG_HOST_EXECUTABLE_SUFFIX} | true")
                z_vcpkg_append_to_configure_environment(configure_env CPP_FOR_BUILD "touch a.out | touch conftest${VCPKG_HOST_EXECUTABLE_SUFFIX} | true")
                z_vcpkg_append_to_configure_environment(configure_env CXX_FOR_BUILD "touch a.out | touch conftest${VCPKG_HOST_EXECUTABLE_SUFFIX} | true")
            endif()
            z_vcpkg_append_to_configure_environment(configure_env CXX "compile ${VCPKG_DETECTED_CMAKE_CXX_COMPILER}")
            z_vcpkg_append_to_configure_environment(configure_env RC "windres-rc ${VCPKG_DETECTED_CMAKE_RC_COMPILER}")
            z_vcpkg_append_to_configure_environment(configure_env WINDRES "windres-rc ${VCPKG_DETECTED_CMAKE_RC_COMPILER}")
            if(VCPKG_DETECTED_CMAKE_AR)
                z_vcpkg_append_to_configure_environment(configure_env AR "ar-lib ${VCPKG_DETECTED_CMAKE_AR}")
            else()
                z_vcpkg_append_to_configure_environment(configure_env AR "ar-lib lib.exe -verbose")
            endif()
        else()
            z_vcpkg_append_to_configure_environment(configure_env CPP "${VCPKG_DETECTED_CMAKE_C_COMPILER} -E")
            z_vcpkg_append_to_configure_environment(configure_env CC "${VCPKG_DETECTED_CMAKE_C_COMPILER}")
            if(NOT arg_BUILD_TRIPLET MATCHES "--host")
                z_vcpkg_append_to_configure_environment(configure_env CC_FOR_BUILD "${VCPKG_DETECTED_CMAKE_C_COMPILER}")
                z_vcpkg_append_to_configure_environment(configure_env CPP_FOR_BUILD "${VCPKG_DETECTED_CMAKE_C_COMPILER} -E")
                z_vcpkg_append_to_configure_environment(configure_env CXX_FOR_BUILD "${VCPKG_DETECTED_CMAKE_CXX_COMPILER}")
            else()
                z_vcpkg_append_to_configure_environment(configure_env CC_FOR_BUILD "touch a.out | touch conftest${VCPKG_HOST_EXECUTABLE_SUFFIX} | true")
                z_vcpkg_append_to_configure_environment(configure_env CPP_FOR_BUILD "touch a.out | touch conftest${VCPKG_HOST_EXECUTABLE_SUFFIX} | true")
                z_vcpkg_append_to_configure_environment(configure_env CXX_FOR_BUILD "touch a.out | touch conftest${VCPKG_HOST_EXECUTABLE_SUFFIX} | true")
            endif()
            z_vcpkg_append_to_configure_environment(configure_env CXX "${VCPKG_DETECTED_CMAKE_CXX_COMPILER}")
            z_vcpkg_append_to_configure_environment(configure_env RC "${VCPKG_DETECTED_CMAKE_RC_COMPILER}")
            z_vcpkg_append_to_configure_environment(configure_env WINDRES "${VCPKG_DETECTED_CMAKE_RC_COMPILER}")
            if(VCPKG_DETECTED_CMAKE_AR)
                z_vcpkg_append_to_configure_environment(configure_env AR "${VCPKG_DETECTED_CMAKE_AR}")
            else()
                z_vcpkg_append_to_configure_environment(configure_env AR "lib.exe -verbose")
            endif()
        endif()
        z_vcpkg_append_to_configure_environment(configure_env LD "${VCPKG_DETECTED_CMAKE_LINKER} -verbose")
        if(VCPKG_DETECTED_CMAKE_RANLIB)
            z_vcpkg_append_to_configure_environment(configure_env RANLIB "${VCPKG_DETECTED_CMAKE_RANLIB}") # 忽略 RANLIB 调用的技巧
        else()
            z_vcpkg_append_to_configure_environment(configure_env RANLIB ":")
        endif()
        if(VCPKG_DETECTED_CMAKE_OBJDUMP) #Objdump 是制作共享库所必需的。否则定义 lt_cv_deplibs_check_method=pass_all
            z_vcpkg_append_to_configure_environment(configure_env OBJDUMP "${VCPKG_DETECTED_CMAKE_OBJDUMP}") # 忽略 RANLIB 调用的技巧
        endif()
        if(VCPKG_DETECTED_CMAKE_STRIP) # 如有需要，请在 portfile 中正确设置 ENV 变量 STRIP
            z_vcpkg_append_to_configure_environment(configure_env STRIP "${VCPKG_DETECTED_CMAKE_STRIP}")
        else()
            z_vcpkg_append_to_configure_environment(configure_env STRIP ":")
            list(APPEND arg_OPTIONS ac_cv_prog_ac_ct_STRIP=:)
        endif()
        if(VCPKG_DETECTED_CMAKE_NM) # 如有需要，请在 portfile 中正确设置 ENV 变量 NM
            z_vcpkg_append_to_configure_environment(configure_env NM "${VCPKG_DETECTED_CMAKE_NM}")
        else()
            # 在这里有一个真正的 nm 会更好！一些符号（主要是导出的变量）使用 dumpbin 作为 nm 时无法正确导入
            # 并且由于某些原因需要 __declspec(dllimport)（与 CMake 中 WINDOWS_EXPORT_ALL_SYMBOLS 的问题相同）
            z_vcpkg_append_to_configure_environment(configure_env NM "dumpbin.exe -symbols -headers")
        endif()
        if(VCPKG_DETECTED_CMAKE_DLLTOOL) # 如有需要，请在 portfile 中正确设置 ENV 变量 DLLTOOL
            z_vcpkg_append_to_configure_environment(configure_env DLLTOOL "${VCPKG_DETECTED_CMAKE_DLLTOOL}")
        else()
            z_vcpkg_append_to_configure_environment(configure_env DLLTOOL "link.exe -verbose -dll")
        endif()
        z_vcpkg_append_to_configure_environment(configure_env CCAS ":")   # 如有需要，请在 portfile 中正确设置 ENV 变量 CCAS
        z_vcpkg_append_to_configure_environment(configure_env AS ":")   # 如有需要，请在 portfile 中正确设置 ENV 变量 AS

        foreach(_env IN LISTS arg_CONFIGURE_ENVIRONMENT_VARIABLES)
            z_vcpkg_append_to_configure_environment(configure_env ${_env} "${${_env}}")
        endforeach()
        debug_message("configure_env: '${configure_env}'")
        # 其他可能有用的控制变量
        # COMPILE 这是用于实际编译 C 源文件的命令。文件名被追加以形成完整的命令行。
        # LINK 这是用于实际链接 C 程序的命令。
        # CXXCOMPILE 用于实际编译 C++ 源文件的命令。文件名被追加以形成完整的命令行。
        # CXXLINK  用于实际链接 C++ 程序的命令。

        # configure 未正确检测的变量。在 release 构建中。
        list(APPEND arg_OPTIONS gl_cv_double_slash_root=yes
                                 ac_cv_func_memmove=yes)
        #list(APPEND arg_OPTIONS lt_cv_deplibs_check_method=pass_all) # 直接忽略 libtool 检查
        if(VCPKG_TARGET_ARCHITECTURE MATCHES "^[Aa][Rr][Mm]64$")
            list(APPEND arg_OPTIONS gl_cv_host_cpu_c_abi=no)
            # arm64 目前需要此项，因为 objdump 输出: "unrecognised machine type (0xaa64) in Import Library Format archive"
            list(APPEND arg_OPTIONS lt_cv_deplibs_check_method=pass_all)
        elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "^[Aa][Rr][Mm]$")
            # arm 目前需要此项，因为 objdump 输出: "unrecognised machine type (0x1c4) in Import Library Format archive"
            list(APPEND arg_OPTIONS lt_cv_deplibs_check_method=pass_all)
        endif()
    else()
        # OSX 不喜欢在 CC/CXX 中使用 CMAKE_C(XX)_COMPILER (cc)，而是更希望使用 gcc/g++
        vcpkg_list(SET z_vcm_all_tools)
        function(z_vcpkg_make_set_env envvar cmakevar)
            if(NOT VCPKG_DETECTED_CMAKE_${cmakevar})
              return()
            endif()
            set(prog "${VCPKG_DETECTED_CMAKE_${cmakevar}}")
            if(NOT DEFINED ENV{${envvar}} AND NOT prog STREQUAL "")
                vcpkg_list(APPEND z_vcm_all_tools "${prog}")
                if(ARGN)
                    string(APPEND prog " ${ARGN}")
                endif()
                set(z_vcm_all_tools "${z_vcm_all_tools}" PARENT_SCOPE)
                set(ENV{${envvar}} "${prog}")
            endif()
        endfunction()
        z_vcpkg_make_set_env(CC C_COMPILER)
        if(NOT arg_BUILD_TRIPLET MATCHES "--host")
            z_vcpkg_make_set_env(CC_FOR_BUILD C_COMPILER)
            z_vcpkg_make_set_env(CPP_FOR_BUILD C_COMPILER "-E")
            z_vcpkg_make_set_env(CXX_FOR_BUILD C_COMPILER)
        else()
            set(ENV{CC_FOR_BUILD} "touch a.out | touch conftest${VCPKG_HOST_EXECUTABLE_SUFFIX} | true")
            set(ENV{CPP_FOR_BUILD} "touch a.out | touch conftest${VCPKG_HOST_EXECUTABLE_SUFFIX} | true")
            set(ENV{CXX_FOR_BUILD} "touch a.out | touch conftest${VCPKG_HOST_EXECUTABLE_SUFFIX} | true")
        endif()
        z_vcpkg_make_set_env(CXX CXX_COMPILER)
        z_vcpkg_make_set_env(NM NM)
        z_vcpkg_make_set_env(RC RC)
        z_vcpkg_make_set_env(WINDRES RC)
        z_vcpkg_make_set_env(DLLTOOL DLLTOOL)
        z_vcpkg_make_set_env(STRIP STRIP)
        z_vcpkg_make_set_env(OBJDUMP OBJDUMP)
        z_vcpkg_make_set_env(RANLIB RANLIB)
        z_vcpkg_make_set_env(AR AR)
        z_vcpkg_make_set_env(LD LINKER)
        unset(z_vcpkg_make_set_env)
    endif()

    list(FILTER z_vcm_all_tools INCLUDE REGEX " ")
    if(z_vcm_all_tools)
        list(REMOVE_DUPLICATES z_vcm_all_tools)
        list(JOIN z_vcm_all_tools "\n   " tools)
        message(STATUS "警告: 工具路径中包含空格可能会被 configure 错误处理:\n   ${tools}")
    endif()

    z_vcpkg_configure_make_common_definitions()

    # 清理之前的构建目录
    file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${short_name_RELEASE}"
                        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${short_name_DEBUG}"
                        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}")

    # 设置配置路径
    vcpkg_list(APPEND arg_OPTIONS_RELEASE "--prefix=${current_installed_dir_msys}")
    vcpkg_list(APPEND arg_OPTIONS_DEBUG "--prefix=${current_installed_dir_msys}${path_suffix_DEBUG}")
    if(NOT arg_NO_ADDITIONAL_PATHS)
        # ${prefix} 有一个额外的反斜杠，以防止在调用 `bash -c configure "..."` 时提前展开。
        vcpkg_list(APPEND arg_OPTIONS_RELEASE
                            # 重要: 这些都应相对于 prefix！
                            "--bindir=\\\${prefix}/tools/${PORT}/bin"
                            "--sbindir=\\\${prefix}/tools/${PORT}/sbin"
                            "--libdir=\\\${prefix}/lib" # 在某些 Linux 发行版中，lib64 是默认值
                            #"--includedir='\${prefix}'/include" # 已经是默认值！
                            "--mandir=\\\${prefix}/share/${PORT}"
                            "--docdir=\\\${prefix}/share/${PORT}"
                            "--datarootdir=\\\${prefix}/share/${PORT}")
        vcpkg_list(APPEND arg_OPTIONS_DEBUG
                            # 重要: 这些都应相对于 prefix！
                            "--bindir=\\\${prefix}/../tools/${PORT}${path_suffix_DEBUG}/bin"
                            "--sbindir=\\\${prefix}/../tools/${PORT}${path_suffix_DEBUG}/sbin"
                            "--libdir=\\\${prefix}/lib" # 在某些 Linux 发行版中，lib64 是默认值
                            "--includedir=\\\${prefix}/../include"
                            "--datarootdir=\\\${prefix}/share/${PORT}")
    endif()
    # 设置通用选项
    if(NOT arg_DISABLE_VERBOSE_FLAGS)
        list(APPEND arg_OPTIONS --disable-silent-rules --verbose)
    endif()

    if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        list(APPEND arg_OPTIONS --enable-shared --disable-static)
    else()
        list(APPEND arg_OPTIONS --disable-shared --enable-static)
    endif()

    # 可以在三元组中设置以追加 configure 选项
    if(DEFINED VCPKG_CONFIGURE_MAKE_OPTIONS)
        list(APPEND arg_OPTIONS ${VCPKG_CONFIGURE_MAKE_OPTIONS})
    endif()
    if(DEFINED VCPKG_CONFIGURE_MAKE_OPTIONS_RELEASE)
        list(APPEND arg_OPTIONS_RELEASE ${VCPKG_CONFIGURE_MAKE_OPTIONS_RELEASE})
    endif()
    if(DEFINED VCPKG_CONFIGURE_MAKE_OPTIONS_DEBUG)
        list(APPEND arg_OPTIONS_DEBUG ${VCPKG_CONFIGURE_MAKE_OPTIONS_DEBUG})
    endif()

    file(RELATIVE_PATH relative_build_path "${CURRENT_BUILDTREES_DIR}" "${arg_SOURCE_PATH}/${arg_PROJECT_SUBPATH}")

    # 用于 CL
    vcpkg_host_path_list(PREPEND ENV{INCLUDE} "${CURRENT_INSTALLED_DIR}/include")
    # 用于 GCC
    vcpkg_host_path_list(PREPEND ENV{C_INCLUDE_PATH} "${CURRENT_INSTALLED_DIR}/include")
    vcpkg_host_path_list(PREPEND ENV{CPLUS_INCLUDE_PATH} "${CURRENT_INSTALLED_DIR}/include")

    # 标志应该在工具链中设置（正确设置需要一个名为 vcpkg_determined_cmake_compiler_flags 的函数，该函数也可用于设置 CC 和 CXX 等。）
    if(VCPKG_TARGET_IS_WINDOWS)
        vcpkg_backup_env_variables(VARS _CL_ _LINK_)
        # TODO: 应该是 CPP 标志 -> 在定义 vcpkg_determined_cmake_compiler_flags 时重写
        if(VCPKG_TARGET_IS_UWP)
            # 请注意，configure 认为这是交叉编译，因为:
            # error while loading shared libraries: VCRUNTIME140D_APP.dll:
            # cannot open shared object file: No such file or directory
            # 重要: 通过 libtool 和编译器 wrapper 传递链接器标志的唯一方式
            # 是使用 CL 和 LINK 环境变量！！！
            # （这是因为 libtool 和编译器 wrapper 使用相同的选项集来传递这些变量）
            file(TO_CMAKE_PATH "$ENV{VCToolsInstallDir}" VCToolsInstallDir)
            set(_replacement -FU\"${VCToolsInstallDir}/lib/x86/store/references/platform.winmd\")
            string(REPLACE "${_replacement}" "" VCPKG_DETECTED_CMAKE_CXX_FLAGS_DEBUG "${VCPKG_DETECTED_CMAKE_CXX_FLAGS_DEBUG}")
            string(REPLACE "${_replacement}" "" VCPKG_DETECTED_CMAKE_C_FLAGS_DEBUG "${VCPKG_DETECTED_CMAKE_C_FLAGS_DEBUG}")
            string(REPLACE "${_replacement}" "" VCPKG_DETECTED_CMAKE_CXX_FLAGS_RELEASE "${VCPKG_DETECTED_CMAKE_CXX_FLAGS_RELEASE}")
            string(REPLACE "${_replacement}" "" VCPKG_DETECTED_CMAKE_C_FLAGS_RELEASE "${VCPKG_DETECTED_CMAKE_C_FLAGS_RELEASE}")
            # 有人能检查一下 CMake 的 UWP 编译器标志是否正确吗？
            set(ENV{_CL_} "$ENV{_CL_} -FU\"${VCToolsInstallDir}/lib/x86/store/references/platform.winmd\"")
            set(ENV{_LINK_} "$ENV{_LINK_} ${VCPKG_DETECTED_CMAKE_C_STANDARD_LIBRARIES} ${VCPKG_DETECTED_CMAKE_CXX_STANDARD_LIBRARIES}")
        endif()
    endif()

    # 移除 cmake 变量的外层引号，这些变量将通过 makefile/shell 变量转发
    # 并替换到 makefile 命令中（例如 Android NDK 有 "--sysroot=..."）
    separate_arguments(c_libs_list NATIVE_COMMAND "${VCPKG_DETECTED_CMAKE_C_STANDARD_LIBRARIES}")
    separate_arguments(cxx_libs_list NATIVE_COMMAND "${VCPKG_DETECTED_CMAKE_CXX_STANDARD_LIBRARIES}")
    list(REMOVE_ITEM cxx_libs_list ${c_libs_list})
    set(all_libs_list ${cxx_libs_list} ${c_libs_list})
    # 如有必要，将库名从 name.lib 转换为 -lname
    set(x_vcpkg_transform_libs ON)
    if(VCPKG_TARGET_IS_UWP)
        set(x_vcpkg_transform_libs OFF)
        # 避免 libtool 噎住: "Warning: linker path does not have real file for library -lWindowsApp."
        # 噎住的问题在于 libtool 总是回退到构建静态库，即使请求的是动态库。
        # 注意: 环境变量 LIBPATH;LIB 默认在 Windows 上是 libtool 的搜索路径。
        # 它甚至对路径进行 unix/dos-short/unix 转换以消除空格。
    endif()
    if(x_vcpkg_transform_libs)
        list(TRANSFORM all_libs_list REPLACE "[.](dll[.]lib|lib|a|so)$" "")
        if(VCPKG_TARGET_IS_WINDOWS)
            list(REMOVE_ITEM all_libs_list "uuid")
        endif()
        list(TRANSFORM all_libs_list REPLACE "^([^-].*)" "-l\\1")
        if(VCPKG_TARGET_IS_MINGW AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
            # 必须明确告诉 libtool uuid 没有动态链接。
            # "-Wl,..." 语法被 libtool 和 gcc 理解，但不被 ld 理解。
            list(TRANSFORM all_libs_list REPLACE "^-luuid\$" "-Wl,-Bstatic,-luuid,-Bdynamic")
        endif()
    endif()
    if(all_libs_list)
        list(JOIN all_libs_list " " all_libs_string)
        if(DEFINED ENV{LIBS})
            set(ENV{LIBS} "$ENV{LIBS} ${all_libs_string}")
        else()
            set(ENV{LIBS} "${all_libs_string}")
        endif()
    endif()
    debug_message("ENV{LIBS}:$ENV{LIBS}")

    # 如有必要，运行 autoconf
    if (arg_AUTOCONFIG OR requires_autoconfig AND NOT arg_NO_AUTOCONFIG)
        find_program(AUTORECONF autoreconf)
        if(NOT AUTORECONF)
            message(FATAL_ERROR "${PORT} 需要从系统包管理器安装 autoconf（例如: \"sudo apt-get install autoconf\"）")
        endif()
        message(STATUS "正在为 ${TARGET_TRIPLET} 生成 configure")
        if (CMAKE_HOST_WIN32)
            vcpkg_execute_required_process(
                COMMAND ${base_cmd} -c "autoreconf -vfi"
                WORKING_DIRECTORY "${src_dir}"
                LOGNAME "autoconf-${TARGET_TRIPLET}"
            )
        else()
            vcpkg_execute_required_process(
                COMMAND "${AUTORECONF}" -vfi
                WORKING_DIRECTORY "${src_dir}"
                LOGNAME "autoconf-${TARGET_TRIPLET}"
            )
        endif()
        message(STATUS "已完成为 ${TARGET_TRIPLET} 生成 configure")
    endif()
    if(requires_autogen)
        message(STATUS "正在通过 autogen.sh 为 ${TARGET_TRIPLET} 生成 configure")
        if (CMAKE_HOST_WIN32)
            vcpkg_execute_required_process(
                COMMAND ${base_cmd} -c "./autogen.sh"
                WORKING_DIRECTORY "${src_dir}"
                LOGNAME "autoconf-${TARGET_TRIPLET}"
            )
        else()
            vcpkg_execute_required_process(
                COMMAND "./autogen.sh"
                WORKING_DIRECTORY "${src_dir}"
                LOGNAME "autoconf-${TARGET_TRIPLET}"
            )
        endif()
        message(STATUS "已完成为 ${TARGET_TRIPLET} 生成 configure")
    endif()

    if (arg_PRERUN_SHELL)
        message(STATUS "正在为 ${TARGET_TRIPLET} 运行前置 shell")
        if (CMAKE_HOST_WIN32)
            vcpkg_execute_required_process(
                COMMAND ${base_cmd} -c "${arg_PRERUN_SHELL}"
                WORKING_DIRECTORY "${src_dir}"
                LOGNAME "prerun-${TARGET_TRIPLET}"
            )
        else()
            vcpkg_execute_required_process(
                COMMAND "${base_cmd}" -c "${arg_PRERUN_SHELL}"
                WORKING_DIRECTORY "${src_dir}"
                LOGNAME "prerun-${TARGET_TRIPLET}"
            )
        endif()
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug" AND NOT arg_NO_DEBUG)
        list(APPEND all_buildtypes DEBUG)
        z_vcpkg_configure_make_process_flags(DEBUG)
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        list(APPEND all_buildtypes RELEASE)
        z_vcpkg_configure_make_process_flags(RELEASE)
    endif()
    list(FILTER z_vcm_all_flags INCLUDE REGEX " ")
    if(z_vcm_all_flags)
        list(REMOVE_DUPLICATES z_vcm_all_flags)
        list(JOIN z_vcm_all_flags "\n   " flags)
        message(STATUS "警告: 参数中嵌入的空格可能会被 configure 错误处理:\n   ${flags}")
    endif()

    foreach(var IN ITEMS arg_OPTIONS arg_OPTIONS_RELEASE arg_OPTIONS_DEBUG)
        vcpkg_list(SET tmp)
        foreach(element IN LISTS "${var}")
            string(REPLACE [["]] [[\"]] element "${element}")
            vcpkg_list(APPEND tmp "\"${element}\"")
        endforeach()
        vcpkg_list(JOIN tmp " " "${var}")
    endforeach()

    foreach(current_buildtype IN LISTS all_buildtypes)
        foreach(ENV_VAR ${arg_CONFIG_DEPENDENT_ENVIRONMENT})
            if(DEFINED ENV{${ENV_VAR}})
                set(backup_config_${ENV_VAR} "$ENV{${ENV_VAR}}")
            endif()
            set(ENV{${ENV_VAR}} "${${ENV_VAR}_${current_buildtype}}")
        endforeach()

        set(target_dir "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${short_name_${current_buildtype}}")
        file(MAKE_DIRECTORY "${target_dir}")
        file(RELATIVE_PATH relative_build_path "${target_dir}" "${src_dir}")

        if(arg_COPY_SOURCE)
            file(COPY "${src_dir}/" DESTINATION "${target_dir}")
            set(relative_build_path .)
        endif()

        # 设置 PKG_CONFIG_PATH
        z_vcpkg_setup_pkgconfig_path(CONFIG "${current_buildtype}")

        # 设置环境
        set(ENV{CPPFLAGS} "${CPPFLAGS_${current_buildtype}}")
        set(ENV{CPPFLAGS_FOR_BUILD} "${CPPFLAGS_${current_buildtype}}")
        set(ENV{CFLAGS} "${CFLAGS_${current_buildtype}}")
        set(ENV{CFLAGS_FOR_BUILD} "${CFLAGS_${current_buildtype}}")
        set(ENV{CXXFLAGS} "${CXXFLAGS_${current_buildtype}}")
        #set(ENV{CXXFLAGS_FOR_BUILD} "${CXXFLAGS_${current_buildtype}}") -> 官方不支持
        set(ENV{RCFLAGS} "${VCPKG_DETECTED_CMAKE_RC_FLAGS_${current_buildtype}}")
        set(ENV{LDFLAGS} "${LDFLAGS_${current_buildtype}}")
        set(ENV{LDFLAGS_FOR_BUILD} "${LDFLAGS_${current_buildtype}}")
        if(ARFLAGS_${current_buildtype} AND NOT (arg_USE_WRAPPERS AND VCPKG_TARGET_IS_WINDOWS))
            # 目标为 windows 且启用了 wrapper 时无法转发 ARFLAGS，因为这会破坏 wrapper
            set(ENV{ARFLAGS} "${ARFLAGS_${current_buildtype}}")
        endif()

        set(env_cc_backup "$ENV{CC}")
        if(VCPKG_TARGET_IS_APPLE)
            # configure 未使用所有标志来检查编译器是否工作...
            set(ENV{CC} "$ENV{CC} $ENV{CPPFLAGS} $ENV{CFLAGS}")
            set(ENV{CC_FOR_BUILD} "$ENV{CC_FOR_BUILD} $ENV{CPPFLAGS} $ENV{CFLAGS}")
        endif()

        if(LINK_ENV_${current_buildtype})
            set(link_config_backup "$ENV{_LINK_}")
            set(ENV{_LINK_} "${LINK_ENV_${current_buildtype}}")
        else()
            unset(link_config_backup)
        endif()

        vcpkg_list(APPEND lib_env_vars LIB LIBPATH LIBRARY_PATH) # LD_LIBRARY_PATH)
        foreach(lib_env_var IN LISTS lib_env_vars)
            if(EXISTS "${CURRENT_INSTALLED_DIR}${path_suffix_${current_buildtype}}/lib")
                vcpkg_host_path_list(PREPEND ENV{${lib_env_var}} "${CURRENT_INSTALLED_DIR}${path_suffix_${current_buildtype}}/lib")
            endif()
            if(EXISTS "${CURRENT_INSTALLED_DIR}${path_suffix_${current_buildtype}}/lib/manual-link")
                vcpkg_host_path_list(PREPEND ENV{${lib_env_var}} "${CURRENT_INSTALLED_DIR}${path_suffix_${current_buildtype}}/lib/manual-link")
            endif()
        endforeach()
        unset(lib_env_vars)

        set(command "${base_cmd}" -c "${configure_env} ./${relative_build_path}/configure ${arg_BUILD_TRIPLET} ${arg_OPTIONS} ${arg_OPTIONS_${current_buildtype}}")

        if(arg_ADD_BIN_TO_PATH)
            set(path_backup $ENV{PATH})
            vcpkg_add_to_path("${CURRENT_INSTALLED_DIR}${path_suffix_${current_buildtype}}/bin")
        endif()
        debug_message("Configure 命令:'${command}'")
        if (NOT arg_SKIP_CONFIGURE)
            message(STATUS "正在配置 ${TARGET_TRIPLET}-${short_name_${current_buildtype}}")
            vcpkg_execute_required_process(
                COMMAND ${command}
                WORKING_DIRECTORY "${target_dir}"
                LOGNAME "config-${TARGET_TRIPLET}-${short_name_${current_buildtype}}"
                SAVE_LOG_FILES config.log
            )
            if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW AND VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
                file(GLOB_RECURSE libtool_files "${target_dir}*/libtool")
                foreach(lt_file IN LISTS libtool_files)
                    file(READ "${lt_file}" _contents)
                    string(REPLACE ".dll.lib" ".lib" _contents "${_contents}")
                    file(WRITE "${lt_file}" "${_contents}")
                endforeach()
            endif()
        endif()
        z_vcpkg_restore_pkgconfig_path()

        if(DEFINED link_config_backup)
            set(ENV{_LINK_} "${link_config_backup}")
        endif()

        if(arg_ADD_BIN_TO_PATH)
            set(ENV{PATH} "${path_backup}")
        endif()
        # 恢复环境（依赖于配置）
        if(VCPKG_TARGET_IS_APPLE)
            set(ENV{CC} "${env_cc_backup}")
        endif()
        foreach(ENV_VAR IN LISTS ${arg_CONFIG_DEPENDENT_ENVIRONMENT})
            if(backup_config_${ENV_VAR})
                set(ENV{${ENV_VAR}} "${backup_config_${ENV_VAR}}")
            else()
                unset(ENV{${ENV_VAR}})
            endif()
        endforeach()
    endforeach()

    # 为 vcpkg_build_make 导出匹配的 make 程序（缓存变量）
    if(CMAKE_HOST_WIN32 AND MSYS_ROOT)
        find_program(Z_VCPKG_MAKE make PATHS "${MSYS_ROOT}/usr/bin" NO_DEFAULT_PATH REQUIRED)
    elseif(VCPKG_HOST_IS_BSD)
        find_program(Z_VCPKG_MAKE gmake REQUIRED)
    elseif(VCPKG_HOST_IS_SOLARIS)
        find_program(Z_VCPKG_MAKE NAMES gmake make REQUIRED)
    else()
        find_program(Z_VCPKG_MAKE make REQUIRED)
    endif()

    # 恢复环境
    vcpkg_restore_env_variables(VARS ${cm_FLAGS} LIB LIBPATH LIBRARY_PATH LD_LIBRARY_PATH)

    set(_VCPKG_PROJECT_SOURCE_PATH ${arg_SOURCE_PATH} PARENT_SCOPE)
    set(_VCPKG_PROJECT_SUBPATH ${arg_PROJECT_SUBPATH} PARENT_SCOPE)
    set(_VCPKG_MAKE_NO_DEBUG ${arg_NO_DEBUG} PARENT_SCOPE)
endfunction()
