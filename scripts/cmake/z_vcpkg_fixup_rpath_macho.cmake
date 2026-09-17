function(z_vcpkg_calculate_corrected_macho_rpath)
    cmake_parse_arguments(PARSE_ARGV 0 "arg"
      ""
      "MACHO_FILE_DIR;OUT_NEW_RPATH_VAR"
      "")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} 被传入了多余的参数：${arg_UNPARSED_ARGUMENTS}")
    endif()

    set(current_prefix "${CURRENT_PACKAGES_DIR}")
    set(current_installed_prefix "${CURRENT_INSTALLED_DIR}")
    file(RELATIVE_PATH relative_from_packages "${CURRENT_PACKAGES_DIR}" "${arg_MACHO_FILE_DIR}")
    if("${relative_from_packages}/" MATCHES "^debug/" OR "${relative_from_packages}/" MATCHES "^(manual-)?tools/.*/debug/.*")
        set(current_prefix "${CURRENT_PACKAGES_DIR}/debug")
        set(current_installed_prefix "${CURRENT_INSTALLED_DIR}/debug")
    endif()

    # 计算相对于 lib 的路径
    file(RELATIVE_PATH relative_to_lib "${arg_MACHO_FILE_DIR}" "${current_prefix}/lib")
    # 移除末尾斜杠
    string(REGEX REPLACE "/+$" "" relative_to_lib "${relative_to_lib}")

    if(NOT relative_to_lib STREQUAL "")
        set(new_rpath "@loader_path/${relative_to_lib}")
    else()
        set(new_rpath "@loader_path")
    endif()

    set("${arg_OUT_NEW_RPATH_VAR}" "${new_rpath}" PARENT_SCOPE)
endfunction()

function(z_vcpkg_regex_escape)
    cmake_parse_arguments(PARSE_ARGV 0 "arg"
      ""
      "STRING;OUT_REGEX_ESCAPED_STRING_VAR"
      "")
  string(REGEX REPLACE "([][+.*()^])" "\\\\\\1" regex_escaped "${arg_STRING}")
  set("${arg_OUT_REGEX_ESCAPED_STRING_VAR}" "${regex_escaped}" PARENT_SCOPE)
endfunction()

function(z_vcpkg_fixup_macho_rpath_in_dir)
    # 我们需要遍历所有内容，因为我们
    # 无法预测 Mach-O 文件的位置
    file(GLOB root_entries LIST_DIRECTORIES TRUE "${CURRENT_PACKAGES_DIR}/*")

    # 跳过部分文件夹以提高处理效率
    list(APPEND folders_to_skip "include")
    list(JOIN folders_to_skip "|" folders_to_skip_regex)
    set(folders_to_skip_regex "^(${folders_to_skip_regex})$")

    find_program(
        install_name_tool_cmd
        NAMES install_name_tool
        DOC "install_name_tool 命令的绝对路径"
        REQUIRED
    )

    find_program(
        otool_cmd
        NAMES otool
        DOC "otool 命令的绝对路径"
        REQUIRED
    )

    find_program(
        file_cmd
        NAMES file
        DOC "file 命令的绝对路径"
        REQUIRED
      )

    foreach(folder IN LISTS root_entries)
        if(NOT IS_DIRECTORY "${folder}")
            continue()
        endif()

        get_filename_component(folder_name "${folder}" NAME)
        if(folder_name MATCHES "${folders_to_skip_regex}")
            continue()
        endif()

        file(GLOB_RECURSE macho_files LIST_DIRECTORIES FALSE "${folder}/*")
        list(FILTER macho_files EXCLUDE REGEX [[\.(cpp|cc|cxx|c|hpp|h|hh|hxx|inc|json|toml|yaml|man|m4|ac|am|in|log|txt|pyi?|pyc|pyx|pxd|pc|cmake|f77|f90|f03|fi|f|cu|mod|ini|whl|cat|csv|rst|md|npy|npz|template|build)$]])
        list(FILTER macho_files EXCLUDE REGEX "/(copyright|LICENSE|METADATA)$")

        foreach(macho_file IN LISTS macho_files)
            if(IS_SYMLINK "${macho_file}")
                continue()
            endif()

            # 判断该文件是否为 Mach-O 可执行文件或共享库
            execute_process(
                COMMAND "${file_cmd}" -b "${macho_file}"
                OUTPUT_VARIABLE file_output
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )
            if(file_output MATCHES ".*Mach-O.*shared library.*")
                set(file_type "shared")
            elseif(file_output MATCHES ".*Mach-O.*executable.*")
                set(file_type "executable")
            else()
                debug_message("文件 `${macho_file}` 报告为 `${file_output}`，不是 Mach-O 文件")
                continue()
            endif()

            list(APPEND macho_executables_and_shared_libs "${macho_file}")

            get_filename_component(macho_file_dir "${macho_file}" DIRECTORY)
            get_filename_component(macho_file_name "${macho_file}" NAME)

            z_vcpkg_calculate_corrected_macho_rpath(
                MACHO_FILE_DIR "${macho_file_dir}"
                OUT_NEW_RPATH_VAR new_rpath
            )

            if("${file_type}" STREQUAL "shared")
                # 为共享库设置安装名
                execute_process(
                    COMMAND "${otool_cmd}" -D "${macho_file}"
                    OUTPUT_VARIABLE get_id_ov
                    RESULT_VARIABLE get_id_rv
                )
                if(NOT get_id_rv EQUAL 0)
                    message(FATAL_ERROR "无法从 '${macho_file}' 获取安装名 ID")
                endif()
                set(macho_new_id "@rpath/${macho_file_name}")
                message(STATUS "正在将 '${macho_file}' 的安装名 ID 设置为 '@rpath/${macho_file_name}'")
                execute_process(
                    COMMAND "${install_name_tool_cmd}" -id "${macho_new_id}" "${macho_file}"
                    OUTPUT_QUIET
                    ERROR_VARIABLE set_id_error
                    RESULT_VARIABLE set_id_exit_code
                )
                if(NOT "${set_id_error}" STREQUAL "" AND NOT set_id_exit_code EQUAL 0)
                    message(WARNING "无法调整 '${macho_file}' 的安装名：${set_id_error}")
                    continue()
                endif()

                # otool -D <macho_file> 通常返回如下格式的行：

                # <macho_file>:
                # <id>

                # 但对于 ARM64 二进制文件，它也可能返回：
                # <macho_file> (architecture arm64):
                # <id>

                # 无论哪种情况，我们都需要移除第一行并去除末尾的换行符。
                string(REGEX REPLACE "[^\n]+:\n" "" get_id_ov "${get_id_ov}")
                string(REGEX REPLACE "\n.*" "" get_id_ov "${get_id_ov}")
                list(APPEND adjusted_shared_lib_old_ids "${get_id_ov}")
                list(APPEND adjusted_shared_lib_new_ids "${macho_new_id}")
            endif()

            # 列出所有现有的 rpath
            execute_process(
                COMMAND "${otool_cmd}" -l "${macho_file}"
                OUTPUT_VARIABLE get_rpath_ov
                RESULT_VARIABLE get_rpath_rv
            )

            if(NOT get_rpath_rv EQUAL 0)
                message(FATAL_ERROR "无法从 '${macho_file}' 获取 rpath 列表")
            endif()
            # 提取 LC_RPATH 加载命令并提取路径
            string(REGEX REPLACE "[^\n]+cmd LC_RPATH\n[^\n]+\n[^\n]+path ([^\n]+) \\(offset[^\n]+\n" "rpath \\1\n" get_rpath_ov "${get_rpath_ov}")
            string(REGEX MATCHALL "rpath [^\n]+" get_rpath_ov "${get_rpath_ov}")
            string(REGEX REPLACE "rpath " "" rpath_list "${get_rpath_ov}")

            list(FIND rpath_list "${new_rpath}" has_new_rpath)
            if(NOT has_new_rpath EQUAL -1)
                list(REMOVE_AT rpath_list ${has_new_rpath})
                set(rpath_args)
            else()
                set(rpath_args -add_rpath "${new_rpath}")
            endif()
            foreach(rpath IN LISTS rpath_list)
                list(APPEND rpath_args "-delete_rpath" "${rpath}")
            endforeach()
            if(NOT rpath_args)
                continue()
            endif()

            # 设置新的 rpath
            execute_process(
                COMMAND "${install_name_tool_cmd}" ${rpath_args} "${macho_file}"
                OUTPUT_QUIET
                ERROR_VARIABLE set_rpath_error
                RESULT_VARIABLE set_rpath_exit_code
            )

            if(NOT "${set_rpath_error}" STREQUAL "" AND NOT set_rpath_exit_code EQUAL 0)
                message(WARNING "无法调整 '${macho_file}' 的 RPATH：${set_rpath_error}")
                continue()
            endif()

            message(STATUS "已将 '${macho_file}' 的 RPATH 调整为 '${new_rpath}'")
        endforeach()
    endforeach()

    # 检查可执行文件和共享库中的依赖库，
    # 这些库在 ID 变更后需要调整
    list(LENGTH adjusted_shared_lib_old_ids last_adjusted_index)
    if(NOT last_adjusted_index EQUAL 0)
        math(EXPR last_adjusted_index "${last_adjusted_index} - 1")
        foreach(macho_file IN LISTS macho_executables_and_shared_libs)
            execute_process(
                COMMAND "${otool_cmd}" -L "${macho_file}"
                OUTPUT_VARIABLE get_deps_ov
                RESULT_VARIABLE get_deps_rv
            )
            if(NOT get_deps_rv EQUAL 0)
                message(FATAL_ERROR "无法从 '${macho_file}' 获取依赖列表")
            endif()
            # 将 adjusted_shared_lib_old_ids[i] 替换为 adjusted_shared_lib_new_ids[i]
            foreach(i RANGE ${last_adjusted_index})
                list(GET adjusted_shared_lib_old_ids ${i} adjusted_old_id)
                z_vcpkg_regex_escape(
                    STRING "${adjusted_old_id}"
                    OUT_REGEX_ESCAPED_STRING_VAR regex
                )
                if(NOT get_deps_ov MATCHES "[ \t]${regex} ")
                    continue()
                endif()
                list(GET adjusted_shared_lib_new_ids ${i} adjusted_new_id)

                # 用新的 ID 替换旧的 ID
                execute_process(
                    COMMAND "${install_name_tool_cmd}" -change "${adjusted_old_id}" "${adjusted_new_id}" "${macho_file}"
                    OUTPUT_QUIET
                    ERROR_VARIABLE change_id_error
                    RESULT_VARIABLE change_id_exit_code
                )
                if(NOT "${change_id_error}" STREQUAL "" AND NOT change_id_exit_code EQUAL 0)
                    message(WARNING "无法调整 '${macho_file}' 中依赖共享库的安装名：${change_id_error}")
                    continue()
                endif()
                message(STATUS "已调整 '${macho_file}' 中依赖共享库的安装名（从 '${adjusted_old_id}' -> 到 '${adjusted_new_id}'）")
            endforeach()
        endforeach()
    endif()
endfunction()
