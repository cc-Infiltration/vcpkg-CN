function(z_vcpkg_calculate_corrected_rpath)
    cmake_parse_arguments(PARSE_ARGV 0 "arg"
      ""
      "ELF_FILE_DIR;ORG_RPATH;OUT_NEW_RPATH_VAR"
      "")

    set(current_prefix "${CURRENT_PACKAGES_DIR}")
    set(current_installed_prefix "${CURRENT_INSTALLED_DIR}")
    file(RELATIVE_PATH relative_from_packages "${CURRENT_PACKAGES_DIR}" "${arg_ELF_FILE_DIR}")
    if("${relative_from_packages}/" MATCHES "^debug/|^(manual-tools|tools)/[^/]*/debug/")
        set(current_prefix "${CURRENT_PACKAGES_DIR}/debug")
        set(current_installed_prefix "${CURRENT_INSTALLED_DIR}/debug")
    endif()

    # 计算相对于 lib 的路径
    file(RELATIVE_PATH relative_to_lib "${arg_ELF_FILE_DIR}" "${current_prefix}/lib")
    # 计算相对于 prefix 的路径
    file(RELATIVE_PATH relative_to_prefix "${arg_ELF_FILE_DIR}" "${current_prefix}")

    set(rpath_norm "")
    if(NOT "${arg_ORG_RPATH}" STREQUAL "")
        cmake_path(CONVERT "${arg_ORG_RPATH}" TO_CMAKE_PATH_LIST rpath_norm)

        # 模式匹配辅助标记
        list(TRANSFORM rpath_norm PREPEND "::")
        list(TRANSFORM rpath_norm APPEND "/")

        string(REPLACE "::${arg_ELF_FILE_DIR}/" "::\$ORIGIN/" rpath_norm "${rpath_norm}")
        # 移除不必要的上下层级；不要使用 normalize，否则 $ORIGIN/../ 会被移除
        string(REPLACE "/lib/pkgconfig/../../" "/" rpath_norm "${rpath_norm}")
        # lib 相对路径修正
        string(REPLACE "::${current_prefix}/lib/" "::\$ORIGIN/${relative_to_lib}/" rpath_norm "${rpath_norm}")
        string(REPLACE "::${current_installed_prefix}/lib/" "::\$ORIGIN/${relative_to_lib}/" rpath_norm "${rpath_norm}")
        # prefix 相对路径
        string(REPLACE "::${current_prefix}/" "::\$ORIGIN/${relative_to_prefix}/" rpath_norm "${rpath_norm}")
        string(REPLACE "::${current_installed_prefix}/" "::\$ORIGIN/${relative_to_prefix}/" rpath_norm "${rpath_norm}")

        if(NOT X_VCPKG_RPATH_KEEP_SYSTEM_PATHS)
            list(FILTER rpath_norm INCLUDE REGEX "::\\\$ORIGIN.+") # 只保留相对于 ORIGIN 的路径
        endif()

        # 路径规范化
        list(TRANSFORM rpath_norm REPLACE "/+" "/")

        # 移除模式匹配辅助标记
        list(TRANSFORM rpath_norm REPLACE "^::" "")
        list(TRANSFORM rpath_norm REPLACE "/\$" "")
    endif()

    if(NOT relative_to_lib STREQUAL "")
        list(PREPEND rpath_norm "\$ORIGIN/${relative_to_lib}")
    endif()
    list(PREPEND rpath_norm "\$ORIGIN") # 将 ORIGIN 设为第一个条目
    list(TRANSFORM rpath_norm REPLACE "/$" "")
    list(REMOVE_DUPLICATES rpath_norm)
    cmake_path(CONVERT "${rpath_norm}" TO_NATIVE_PATH_LIST new_rpath)

    set("${arg_OUT_NEW_RPATH_VAR}" "${new_rpath}" PARENT_SCOPE)
endfunction()

function(z_vcpkg_fixup_rpath_in_dir)
    # 我们需要遍历所有内容，因为我们
    # 无法预测 elf 文件的位置
    file(GLOB root_entries LIST_DIRECTORIES TRUE "${CURRENT_PACKAGES_DIR}/*")

    # 跳过部分文件夹以提高处理效率
    list(APPEND folders_to_skip "include")
    list(JOIN folders_to_skip "|" folders_to_skip_regex)
    set(folders_to_skip_regex "^(${folders_to_skip_regex})$")

    # 在下载模式下，我们不知道是否需要 PATCHELF，所以悲观地预先获取它，
    # 让它留在下载目录中。
    if(VCPKG_DOWNLOAD_MODE)
        vcpkg_find_acquire_program(PATCHELF)
    endif()

    foreach(folder IN LISTS root_entries)
        if(NOT IS_DIRECTORY "${folder}")
            continue()
        endif()

        get_filename_component(folder_name "${folder}" NAME)
        if(folder_name MATCHES "${folders_to_skip_regex}")
            continue()
        endif()

        file(GLOB_RECURSE elf_files LIST_DIRECTORIES FALSE "${folder}/*")
        list(FILTER elf_files EXCLUDE REGEX "\\\.(a|cpp|cc|cxx|c|hpp|h|hh|hxx|inc|json|toml|yaml|man|m4|ac|am|in|log|txt|pyi?|pyc|pyx|pxd|pc|cmake|f77|f90|f03|fi|f|cu|mod|ini|whl|cat|csv|rst|md|npy|npz|template|build)$")
        list(FILTER elf_files EXCLUDE REGEX "/(copyright|LICENSE|METADATA)$")

        foreach(elf_file IN LISTS elf_files)
            if(IS_SYMLINK "${elf_file}")
                continue()
            endif()

            vcpkg_find_acquire_program(PATCHELF) # 注意：这依赖于 vcpkg_find_acquire_program 在
                                                 # 第一次运行后的短路机制
            # 如果失败，说明该文件不是 elf 文件
            execute_process(
                COMMAND "${PATCHELF}" --print-rpath "${elf_file}"
                OUTPUT_VARIABLE readelf_output
                ERROR_VARIABLE read_rpath_error
            )
            string(REPLACE "\n" "" readelf_output "${readelf_output}")
            if(NOT "${read_rpath_error}" STREQUAL "")
                continue()
            endif()

            get_filename_component(elf_file_dir "${elf_file}" DIRECTORY)

            z_vcpkg_calculate_corrected_rpath(
              ELF_FILE_DIR "${elf_file_dir}"
              ORG_RPATH "${readelf_output}"
              OUT_NEW_RPATH_VAR new_rpath
            )

            execute_process(
                COMMAND "${PATCHELF}" --set-rpath "${new_rpath}" "${elf_file}"
                OUTPUT_QUIET
                ERROR_VARIABLE set_rpath_error
            )

            if(NOT "${set_rpath_error}" STREQUAL "")
                message(WARNING "无法调整 '${elf_file}' 的 RPATH：${set_rpath_error}")
                continue()
            endif()

            message(STATUS "已调整 '${elf_file}' 的 RPATH（从 '${readelf_output}' -> 到 '${new_rpath}'）")
        endforeach()
    endforeach()
endfunction()
