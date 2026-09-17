function(z_vcpkg_extract_source_archive_deprecated_mode archive working_directory)
    cmake_path(GET archive FILENAME archive_filename)
    if(NOT EXISTS "${working_directory}/${archive_filename}.extracted")
        message(STATUS "正在解压源码 ${archive}")
        vcpkg_extract_archive(ARCHIVE "${archive}" DESTINATION "${working_directory}")
        file(TOUCH "${working_directory}/${archive_filename}.extracted")
    endif()
endfunction()

function(vcpkg_extract_source_archive)
    if(ARGC LESS_EQUAL "2")
        z_vcpkg_deprecation_message( "使用了已弃用的 vcpkg_extract_source_archive 形式：
    请使用 `vcpkg_extract_source_archive(<out-var> ARCHIVE <archive>)` 形式。")
        if(ARGC EQUAL "0")
            message(FATAL_ERROR "vcpkg_extract_source_archive 至少需要一个参数。")
        endif()

        set(archive "${ARGV0}")
        if(ARGC EQUAL "1")
            set(working_directory "${CURRENT_BUILDTREES_DIR}/src")
        else()
            set(working_directory "${ARGV1}")
        endif()

        z_vcpkg_extract_source_archive_deprecated_mode("${archive}" "${working_directory}")
        return()
    endif()

    set(out_source_path "${ARGV0}")
    cmake_parse_arguments(PARSE_ARGV 1 "arg"
        "NO_REMOVE_ONE_LEVEL;SKIP_PATCH_CHECK;Z_ALLOW_OLD_PARAMETER_NAMES"
        "ARCHIVE;SOURCE_BASE;BASE_DIRECTORY;WORKING_DIRECTORY;REF"
        "PATCHES"
    )

    if(DEFINED arg_REF)
        if(NOT arg_Z_ALLOW_OLD_PARAMETER_NAMES)
            message(FATAL_ERROR "意外的参数 REF")
        elseif(DEFINED arg_SOURCE_BASE)
            message(FATAL_ERROR "不能同时指定 REF 和 SOURCE_BASE")
        else()
            string(REPLACE "/" "-" arg_SOURCE_BASE "${arg_REF}")
        endif()
    endif()

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} 被传递了多余的参数: ${arg_UNPARSED_ARGUMENTS}")
    endif()
    if(NOT DEFINED arg_ARCHIVE)
        message(FATAL_ERROR "必须指定 ARCHIVE")
    endif()

    if(DEFINED arg_WORKING_DIRECTORY)
        if(DEFINED arg_BASE_DIRECTORY)
            message(FATAL_ERROR "不能同时指定 BASE_DIRECTORY 和 WORKING_DIRECTORY")
        elseif(NOT IS_ABSOLUTE "${arg_WORKING_DIRECTORY}")
            message(FATAL_ERROR "WORKING_DIRECTORY (${arg_WORKING_DIRECTORY}) 必须是绝对路径")
        endif()
        set(working_directory "${arg_WORKING_DIRECTORY}")
    else()
        if(NOT DEFINED arg_BASE_DIRECTORY)
            set(arg_BASE_DIRECTORY "src")
        elseif(IS_ABSOLUTE "${arg_BASE_DIRECTORY}")
            message(FATAL_ERROR "BASE_DIRECTORY (${arg_BASE_DIRECTORY}) 必须是相对路径")
        endif()
        cmake_path(APPEND CURRENT_BUILDTREES_DIR "${arg_BASE_DIRECTORY}"
            OUTPUT_VARIABLE working_directory)
    endif()

    if(NOT DEFINED arg_SOURCE_BASE)
        cmake_path(GET arg_ARCHIVE STEM arg_SOURCE_BASE)
    elseif(arg_SOURCE_BASE MATCHES [[\\|/]])
        message(FATAL_ERROR "SOURCE_BASE (${arg_SOURCE_BASE}) 不能包含斜杠")
    endif()

    # 取基名的最后 10 个字符
    set(base_max_length 10)
    string(LENGTH "${arg_SOURCE_BASE}" source_base_length)
    if(source_base_length GREATER base_max_length)
        math(EXPR start "${source_base_length} - ${base_max_length}")
        string(SUBSTRING "${arg_SOURCE_BASE}" "${start}" -1 arg_SOURCE_BASE)
    endif()

    # 对归档哈希和补丁一起进行哈希计算。取哈希值的前 10 个字符
    file(SHA512 "${arg_ARCHIVE}" patchset_hash)
    foreach(patch IN LISTS arg_PATCHES)
        cmake_path(ABSOLUTE_PATH patch
            BASE_DIRECTORY "${CURRENT_PORT_DIR}"
            OUTPUT_VARIABLE absolute_patch
        )
        if(NOT EXISTS "${absolute_patch}")
            message(FATAL_ERROR "找不到补丁: '${patch}'")
        endif()
        file(SHA512 "${absolute_patch}" current_hash)
        string(APPEND patchset_hash "${current_hash}")
    endforeach()

    string(SHA512 patchset_hash "${patchset_hash}")
    string(SUBSTRING "${patchset_hash}" 0 10 patchset_hash)
    cmake_path(APPEND working_directory "${arg_SOURCE_BASE}-${patchset_hash}"
        OUTPUT_VARIABLE source_path
    )

    if(_VCPKG_EDITABLE AND EXISTS "${source_path}")
        set("${out_source_path}" "${source_path}" PARENT_SCOPE)
        message(STATUS "使用位于 ${source_path} 的源码")
        return()
    elseif(NOT _VCPKG_EDITABLE)
        cmake_path(APPEND_STRING source_path ".clean")
        if(EXISTS "${source_path}")
            message(STATUS "正在清理位于 ${source_path} 的源码。使用 --editable 可跳过您指定的包的清理。")
            file(REMOVE_RECURSE "${source_path}")
        endif()
    endif()

    message(STATUS "正在解压源码 ${arg_ARCHIVE}")
    cmake_path(APPEND_STRING source_path ".tmp" OUTPUT_VARIABLE temp_dir)
    file(REMOVE_RECURSE "${temp_dir}")
    file(MAKE_DIRECTORY "${temp_dir}")
    vcpkg_execute_required_process(
        ALLOW_IN_DOWNLOAD_MODE
        COMMAND "${CMAKE_COMMAND}" -E tar xjf "${arg_ARCHIVE}"
        WORKING_DIRECTORY "${temp_dir}"
        LOGNAME extract
    )

    if(arg_NO_REMOVE_ONE_LEVEL)
        cmake_path(SET temp_source_path "${temp_dir}")
    else()
        file(GLOB archive_directory "${temp_dir}/*")
        # 排除 macOS 的 finder 创建的 .DS_Store 条目
        list(FILTER archive_directory EXCLUDE REGEX ".*/.DS_Store$")
        # 确保 `archive_directory` 只是一个单独的文件
        if(NOT archive_directory MATCHES ";" AND IS_DIRECTORY "${archive_directory}")
            cmake_path(SET temp_source_path "${archive_directory}")
        else()
            message(FATAL_ERROR "无法从归档中展开顶层目录。传递 NO_REMOVE_ONE_LEVEL 可禁用此操作。")
        endif()
    endif()

    if (arg_SKIP_PATCH_CHECK)
        set(quiet_param QUIET)
    else()
        set(quiet_param "")
    endif()

    z_vcpkg_apply_patches(
        SOURCE_PATH "${temp_source_path}"
        PATCHES ${arg_PATCHES}
        ${quiet_param}
    )

    file(RENAME "${temp_source_path}" "${source_path}")
    file(REMOVE_RECURSE "${temp_dir}")

    set("${out_source_path}" "${source_path}" PARENT_SCOPE)
    message(STATUS "使用位于 ${source_path} 的源码")
endfunction()
