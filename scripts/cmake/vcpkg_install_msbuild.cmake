function(vcpkg_install_msbuild)
    cmake_parse_arguments(
        PARSE_ARGV 0
        "arg"
        "USE_VCPKG_INTEGRATION;ALLOW_ROOT_INCLUDES;REMOVE_ROOT_INCLUDES;SKIP_CLEAN"
        "SOURCE_PATH;PROJECT_SUBPATH;INCLUDES_SUBPATH;LICENSE_SUBPATH;RELEASE_CONFIGURATION;DEBUG_CONFIGURATION;PLATFORM;PLATFORM_TOOLSET;TARGET_PLATFORM_VERSION;TARGET"
        "OPTIONS;OPTIONS_RELEASE;OPTIONS_DEBUG"
    )

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "vcpkg_install_msbuild 被传递了多余的参数: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    if(NOT DEFINED arg_RELEASE_CONFIGURATION)
        set(arg_RELEASE_CONFIGURATION Release)
    endif()
    if(NOT DEFINED arg_DEBUG_CONFIGURATION)
        set(arg_DEBUG_CONFIGURATION Debug)
    endif()
    if(NOT DEFINED arg_PLATFORM)
        if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
            set(arg_PLATFORM x64)
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
            set(arg_PLATFORM Win32)
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
            set(arg_PLATFORM ARM)
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
            set(arg_PLATFORM arm64)
        else()
            message(FATAL_ERROR "不支持的目标架构")
        endif()
    endif()
    if(NOT DEFINED arg_PLATFORM_TOOLSET)
        set(arg_PLATFORM_TOOLSET "${VCPKG_PLATFORM_TOOLSET}")
    endif()
    if(NOT DEFINED arg_TARGET_PLATFORM_VERSION)
        vcpkg_get_windows_sdk(arg_TARGET_PLATFORM_VERSION)
    endif()
    if(NOT DEFINED arg_TARGET)
        set(arg_TARGET Rebuild)
    endif()

    list(APPEND arg_OPTIONS
        "/t:${arg_TARGET}"
        "/p:Platform=${arg_PLATFORM}"
        "/p:PlatformToolset=${arg_PLATFORM_TOOLSET}"
        "/p:VCPkgLocalAppDataDisabled=true"
        "/p:UseIntelMKL=No"
        "/p:WindowsTargetPlatformVersion=${arg_TARGET_PLATFORM_VERSION}"
        "/p:VcpkgTriplet=${TARGET_TRIPLET}"
        "/p:VcpkgInstalledDir=${_VCPKG_INSTALLED_DIR}"
        "/p:VcpkgManifestInstall=false"
        "/p:UseMultiToolTask=true"
        "/p:MultiProcMaxCount=${VCPKG_CONCURRENCY}"
        "/p:EnforceProcessCountAcrossBuilds=true"
        "/m:${VCPKG_CONCURRENCY}"
    )

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        # 对静态库禁用 LTCG，因为此设置会在编译器次要版本之间引入 ABI 不兼容性
        # TODO: 为用户添加一种选择加入此不兼容性的方式
        list(APPEND arg_OPTIONS "/p:WholeProgramOptimization=false")
    endif()

    if(arg_USE_VCPKG_INTEGRATION)
        list(APPEND arg_OPTIONS
            "/p:ForceImportBeforeCppTargets=${SCRIPTS}/buildsystems/msbuild/vcpkg.targets"
            "/p:VcpkgApplocalDeps=false"
        )
    endif()

    get_filename_component(source_path_suffix "${arg_SOURCE_PATH}" NAME)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        message(STATUS "正在为 Release 构建 ${arg_PROJECT_SUBPATH}")
        file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
        file(MAKE_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
        file(COPY "${arg_SOURCE_PATH}" DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
        set(source_copy_path "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${source_path_suffix}")
        vcpkg_execute_required_process(
            COMMAND msbuild "${source_copy_path}/${arg_PROJECT_SUBPATH}"
                "/p:Configuration=${arg_RELEASE_CONFIGURATION}"
                ${arg_OPTIONS}
                ${arg_OPTIONS_RELEASE}
            WORKING_DIRECTORY "${source_copy_path}"
            LOGNAME "build-${TARGET_TRIPLET}-rel"
        )
        file(GLOB_RECURSE libs "${source_copy_path}/*.lib")
        file(GLOB_RECURSE dlls "${source_copy_path}/*.dll")
        file(GLOB_RECURSE exes "${source_copy_path}/*.exe")
        if(NOT libs STREQUAL "")
            file(COPY ${libs} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
        endif()
        if(NOT dlls STREQUAL "")
            file(COPY ${dlls} DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
        endif()
        if(NOT exes STREQUAL "")
            file(COPY ${exes} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
            vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")
        endif()
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        message(STATUS "正在为 Debug 构建 ${arg_PROJECT_SUBPATH}")
        file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
        file(MAKE_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
        file(COPY "${arg_SOURCE_PATH}" DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
        set(source_copy_path "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/${source_path_suffix}")
        vcpkg_execute_required_process(
            COMMAND msbuild "${source_copy_path}/${arg_PROJECT_SUBPATH}"
                "/p:Configuration=${arg_DEBUG_CONFIGURATION}"
                ${arg_OPTIONS}
                ${arg_OPTIONS_DEBUG}
            WORKING_DIRECTORY "${source_copy_path}"
            LOGNAME "build-${TARGET_TRIPLET}-dbg"
        )
        file(GLOB_RECURSE libs "${source_copy_path}/*.lib")
        file(GLOB_RECURSE dlls "${source_copy_path}/*.dll")
        if(NOT libs STREQUAL "")
            file(COPY ${libs} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
        endif()
        if(NOT dlls STREQUAL "")
            file(COPY ${dlls} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
        endif()
    endif()

    vcpkg_copy_pdbs()

    if(NOT arg_SKIP_CLEAN)
        vcpkg_clean_msbuild()
    endif()

    if(DEFINED arg_INCLUDES_SUBPATH)
        file(COPY "${arg_SOURCE_PATH}/${arg_INCLUDES_SUBPATH}/"
            DESTINATION "${CURRENT_PACKAGES_DIR}/include/"
        )
        file(GLOB_RECURSE all_am_file "${CURRENT_PACKAGES_DIR}/include/*.am")
        file(GLOB_RECURSE all_in_file "${CURRENT_PACKAGES_DIR}/include/*.in")
        if(NOT "${all_am_file}" STREQUAL "")
            file(REMOVE ${all_am_file})
        endif()
        if(NOT "${all_in_file}" STREQUAL "")
            file(REMOVE ${all_in_file})
        endif()
        file(GLOB root_includes
            LIST_DIRECTORIES false
            "${CURRENT_PACKAGES_DIR}/include/*")
        if(NOT root_includes STREQUAL "")
            if(arg_REMOVE_ROOT_INCLUDES)
                file(REMOVE ${root_includes})
            elseif(arg_ALLOW_ROOT_INCLUDES)
            else()
                message(FATAL_ERROR "在 ${CURRENT_PACKAGES_DIR}/include 中发现了顶层文件；这可能表明调用 `vcpkg_install_msbuild()` 时存在问题。\n为避免与其他库冲突，建议不要将头文件放在根 `include/` 目录中。\n请传递 ALLOW_ROOT_INCLUDES 或 REMOVE_ROOT_INCLUDES 来处理这些文件。\n")
            endif()
        endif()
    endif()

    if(DEFINED arg_LICENSE_SUBPATH)
        file(INSTALL "${arg_SOURCE_PATH}/${arg_LICENSE_SUBPATH}"
            DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
            RENAME copyright
        )
    endif()
endfunction()
