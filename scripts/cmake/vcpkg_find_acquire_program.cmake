function(z_vcpkg_find_acquire_program_version_check out_var)
    cmake_parse_arguments(PARSE_ARGV 1 arg
        "EXACT_VERSION_MATCH"
        "MIN_VERSION;PROGRAM_NAME"
        "COMMAND"
    )
    vcpkg_execute_in_download_mode(
        COMMAND ${arg_COMMAND}
        WORKING_DIRECTORY "${VCPKG_ROOT_DIR}"
        OUTPUT_VARIABLE program_version_output
    )
    string(STRIP "${program_version_output}" program_version_output)
    #TODO: 为更复杂的情况添加正则匹配！
    set(version_compare VERSION_GREATER_EQUAL)
    set(version_compare_msg "at least")
    if(arg_EXACT_VERSION_MATCH)
        set(version_compare VERSION_EQUAL)
        set(version_compare_msg "exact")
    endif()
    if(NOT "${program_version_output}" ${version_compare} "${arg_MIN_VERSION}")
        message(STATUS "找到了 ${arg_PROGRAM_NAME}('${program_version_output}')，但需要${version_compare_msg}版本 ${arg_MIN_VERSION}！尝试尽可能使用内部版本！")
        set("${out_var}" OFF PARENT_SCOPE)
    else()
        message(STATUS "找到外部 ${arg_PROGRAM_NAME}('${program_version_output}')。")
        set("${out_var}" ON PARENT_SCOPE)
    endif()
endfunction()

function(z_vcpkg_find_acquire_program_find_external program)
    cmake_parse_arguments(PARSE_ARGV 1 arg
        "EXACT_VERSION_MATCH"
        "INTERPRETER;MIN_VERSION;PROGRAM_NAME"
        "NAMES;VERSION_COMMAND"
    )
    if(arg_EXACT_VERSION_MATCH)
        set(arg_EXACT_VERSION_MATCH EXACT_VERSION_MATCH)
    endif()

    if("${arg_INTERPRETER}" STREQUAL "")
        find_program("${program}" NAMES ${arg_NAMES})
    else()
        find_file(SCRIPT_${arg_PROGRAM_NAME} NAMES ${arg_NAMES})
        if(SCRIPT_${arg_PROGRAM_NAME})
            vcpkg_list(SET program_tmp ${${interpreter}} ${SCRIPT_${arg_PROGRAM_NAME}})
            set("${program}" "${program_tmp}" CACHE INTERNAL "")
        else()
            set("${program}" "" CACHE INTERNAL "")
        endif()
        unset(SCRIPT_${arg_PROGRAM_NAME} CACHE)
    endif()

    set(${program} "$CACHE{${program}}")
    if("${version_command}" STREQUAL "")
        set(version_is_good ON) # 无法检查版本是否合适，所以假设它是合适的
    elseif(${program}) # 仅当 ${program} 有值时才进行版本检查
        z_vcpkg_find_acquire_program_version_check(version_is_good
            ${arg_EXACT_VERSION_MATCH}
            COMMAND ${${program}} ${arg_VERSION_COMMAND}
            MIN_VERSION "${arg_MIN_VERSION}"
            PROGRAM_NAME "${arg_PROGRAM_NAME}"
        )
    endif()

    if(version_is_good)
        set(${program} "$CACHE{${program}}" PARENT_SCOPE)
    else()
        set("${program}" "${program}-NOTFOUND" PARENT_SCOPE)
        unset("${program}" CACHE)
    endif()
endfunction()

function(z_vcpkg_find_acquire_program_find_internal program)
    cmake_parse_arguments(PARSE_ARGV 1 arg
        ""
        "INTERPRETER"
        "NAMES;PATHS"
    )
    if("${arg_INTERPRETER}" STREQUAL "")
        find_program(${program}
            NAMES ${arg_NAMES}
            PATHS ${arg_PATHS}
            NO_DEFAULT_PATH)
    else()
        vcpkg_find_acquire_program("${arg_INTERPRETER}")
        find_file(SCRIPT_${program}
            NAMES ${arg_NAMES}
            PATHS ${arg_PATHS}
            NO_DEFAULT_PATH)
        if(SCRIPT_${program})
            if(arg_INTERPRETER MATCHES "PYTHON")
              set("${program}" ${${arg_INTERPRETER}} -I ${SCRIPT_${program}} CACHE INTERNAL "")
            else()
              set("${program}" ${${arg_INTERPRETER}} ${SCRIPT_${program}} CACHE INTERNAL "")
            endif()
        endif()
        unset(SCRIPT_${program} CACHE)
    endif()
    set(${program} "$CACHE{${program}}" PARENT_SCOPE)
endfunction()

function(z_use_vcpkg_fetch program)
    cmake_parse_arguments(PARSE_ARGV 1 arg
        ""
        "FETCH_NAME"
        ""
    )
    if(NOT arg_FETCH_NAME)
      string(TOLOWER "${program}" arg_FETCH_NAME)
    endif()
    vcpkg_execute_in_download_mode(
        COMMAND "$ENV{VCPKG_COMMAND}" fetch "${arg_FETCH_NAME}" --x-stderr-status
        OUTPUT_VARIABLE ${program}
        OUTPUT_STRIP_TRAILING_WHITESPACE
        COMMAND_ERROR_IS_FATAL ANY
    )
    set("${program}" "${${program}}" CACHE STRING "" FORCE)
    set(z_uses_vcpkg_fetch ON PARENT_SCOPE)
endfunction()

function(vcpkg_find_acquire_program program)
    if(${program})
        return()
    endif()

    set(raw_executable "OFF")
    set(program_name "")
    set(program_version "")
    set(search_names "")
    set(download_urls "")
    set(download_filename "")
    set(download_sha512 "")
    set(rename_binary_to "")
    set(tool_subdirectory "")
    set(interpreter "")
    set(post_install_command "")
    set(paths_to_search "")
    set(version_command "")
    vcpkg_list(SET sourceforge_args)
    set(brew_package_name "")
    set(apt_package_name "")

    set(program_information "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/vcpkg_find_acquire_program(${program}).cmake")
    if(program MATCHES "^[A-Z0-9]+\$" AND EXISTS "${program_information}")
        include("${program_information}")
        if(z_uses_vcpkg_fetch)
          return()
        endif()
    else()
        message(FATAL_ERROR "未知工具 ${program} -- 无法获取。")
    endif()

    if("${program_name}" STREQUAL "")
        message(FATAL_ERROR "内部错误: 未能为程序 ${program} 初始化 program_name")
    endif()

    set(full_subdirectory "${DOWNLOADS}/tools/${program_name}/${tool_subdirectory}")
    if(NOT "${tool_subdirectory}" STREQUAL "")
        list(APPEND paths_to_search ${full_subdirectory})
    endif()
    if("${full_subdirectory}" MATCHES [[^(.*)[/\\]+$]])
        # 移除尾部斜杠，因为尾部斜杠可能变成尾部 `\`，CMake _不喜欢_ 这个
        set(full_subdirectory "${CMAKE_MATCH_1}")
    endif()

    if("${search_names}" STREQUAL "")
        set(search_names "${program_name}")
    endif()

    # 强制嵌套的 `find_program` 要么使用缓存变量，
    # 要么实际搜索，不受父作用域变量的影响。
    # 被调用的函数必须在此作用域中更改变量。
    if("$CACHE{${program}}" STREQUAL "")
        set(${program} "NOTFOUND")
    else()
        set(${program} "$CACHE{${program}}")
    endif()

    z_vcpkg_find_acquire_program_find_internal("${program}"
        INTERPRETER "${interpreter}"
        PATHS ${paths_to_search}
        NAMES ${search_names}
    )
    if(NOT ${program})
        z_vcpkg_find_acquire_program_find_external("${program}"
            ${extra_search_args}
            PROGRAM_NAME "${program_name}"
            MIN_VERSION "${program_version}"
            INTERPRETER "${interpreter}"
            NAMES ${search_names}
            VERSION_COMMAND ${version_command}
        )
    endif()

    if(NOT ${program})
        if("${download_urls}" STREQUAL "" AND "${sourceforge_args}" STREQUAL "")
            set(example ".")
            if(NOT "${brew_package_name}" STREQUAL "" AND VCPKG_HOST_IS_OSX)
                set(example ":\n    brew install ${brew_package_name}")
            elseif(NOT "${apt_package_name}" STREQUAL "" AND VCPKG_HOST_IS_LINUX)
                set(example ":\n    sudo apt-get install ${apt_package_name}")
            endif()
            message(FATAL_ERROR "找不到 ${program_name}。请通过包管理器安装${example}")
        endif()

        if("${sourceforge_args}" STREQUAL "")
            z_vcpkg_download_distfile(archive_path
                URLS ${download_urls}
                SHA512 "${download_sha512}"
                FILENAME "${download_filename}"
            )
        else()
            vcpkg_download_sourceforge(archive_path
                ${sourceforge_args}
                SHA512 "${download_sha512}"
                FILENAME "${download_filename}"
            )
        endif()
        if(raw_executable)
            file(MAKE_DIRECTORY "${full_subdirectory}")
            if("${rename_binary_to}" STREQUAL "")
                file(COPY "${archive_path}"
                    DESTINATION "${full_subdirectory}"
                    FILE_PERMISSIONS
                        OWNER_READ OWNER_WRITE OWNER_EXECUTE
                        GROUP_READ GROUP_EXECUTE
                        WORLD_READ WORLD_EXECUTE
                )
            else()
                file(INSTALL "${archive_path}"
                    DESTINATION "${full_subdirectory}"
                    RENAME "${rename_binary_to}"
                    FILE_PERMISSIONS
                        OWNER_READ OWNER_WRITE OWNER_EXECUTE
                        GROUP_READ GROUP_EXECUTE
                        WORLD_READ WORLD_EXECUTE
                )
            endif()
        elseif(tool_subdirectory STREQUAL "")
            # 有效的工具子目录由归档文件的解压路径所拥有。
            # *** 提供此行为是为了方便和缩短路径。***
            # 不同子目录提供者之间不能有重叠。
            # 否则必须使用 tool_subdirectory 来分隔解压的目录树。
            file(REMOVE_RECURSE "${full_subdirectory}.temp")
            vcpkg_extract_archive(ARCHIVE "${archive_path}" DESTINATION "${full_subdirectory}.temp")
            file(COPY "${full_subdirectory}.temp/" DESTINATION "${full_subdirectory}")
            file(REMOVE_RECURSE "${full_subdirectory}.temp")
        else()
            vcpkg_extract_archive(ARCHIVE "${archive_path}" DESTINATION "${full_subdirectory}")
        endif()

        if(NOT "${post_install_command}" STREQUAL "")
            vcpkg_execute_required_process(
                ALLOW_IN_DOWNLOAD_MODE
                COMMAND ${post_install_command}
                WORKING_DIRECTORY "${full_subdirectory}"
                LOGNAME "${program}-tool-post-install"
            )
        endif()
        unset("${program}")
        unset("${program}" CACHE)
        z_vcpkg_find_acquire_program_find_internal("${program}"
            INTERPRETER "${interpreter}"
            PATHS ${paths_to_search}
            NAMES ${search_names}
        )
        if(NOT ${program})
            message(FATAL_ERROR "无法找到 ${program}")
        endif()
    endif()

    set("${program}" "${${program}}" PARENT_SCOPE)
endfunction()
