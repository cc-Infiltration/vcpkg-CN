function(z_vcpkg_fixup_pkgconfig_process_data arg_variable arg_config arg_prefix)
    # 此步骤将所有数据规范化为以换行符开头和结尾，
    # 并使用 LF 代替 CRLF。这样可以使用更简单的正则匹配。
    string(REPLACE "\r\n" "\n" contents "\n${${arg_variable}}\n")

    # 我们使用 ${pcfiledir} 来实现可重定位的 pc 文件，在 Windows 上，
    # pkgconf 会将 ${pc_sysrootdir} 初始化为无效的 '/'。
    string(REPLACE [[${pc_sysrootdir}]] "" contents "${contents}")

    string(REPLACE "${CURRENT_PACKAGES_DIR}" [[${prefix}]] contents "${contents}")
    string(REPLACE "${CURRENT_INSTALLED_DIR}" [[${prefix}]] contents "${contents}")
    if(VCPKG_HOST_IS_WINDOWS)
        string(REGEX REPLACE "^([a-zA-Z]):/" [[/\1/]] unix_packages_dir "${CURRENT_PACKAGES_DIR}")
        string(REPLACE "${unix_packages_dir}" [[${prefix}]] contents "${contents}")
        string(REGEX REPLACE "^([a-zA-Z]):/" [[/\1/]] unix_installed_dir "${CURRENT_INSTALLED_DIR}")
        string(REPLACE "${unix_installed_dir}" [[${prefix}]] contents "${contents}")
    endif()

    string(REGEX REPLACE "\n[\t ]*prefix[\t ]*=[^\n]*" "" contents "prefix=${arg_prefix}${contents}")
    if("${arg_config}" STREQUAL "DEBUG")
        # prefix 指向 debug 子文件夹
        string(REPLACE [[${prefix}/debug]] [[${prefix}]] contents "${contents}")
        string(REPLACE [[${prefix}/include]] [[${prefix}/../include]] contents "${contents}")
        string(REPLACE [[${prefix}/share]] [[${prefix}/../share]] contents "${contents}")
    endif()
    # 在转换之前移除行续行符
    string(REGEX REPLACE "[ \t]*\\\\\n[ \t]*" " " contents "${contents}")
    # 本节根据 VCPKG_LIBRARY_LINKAGE 将 XYZ.private 和 XYZ 合并
    #
    # Pkgconfig 在动态情况下会传递搜索 Requires.private 的 Cflags，
    # 这导致我们无法移除它。
    #
    # 一旦此转换完成，vcpkg 的用户将永远不需要传递
    # --static。
    if("${VCPKG_LIBRARY_LINKAGE}" STREQUAL "static")
        # 工作原理：
        # 我们想要转换：
        #   Libs: $1
        #   Libs.private: $2
        # 为
        #    Libs: $1 $2
        # 对于 Requires 和 Requires.private 也做同样的处理

        foreach(item IN ITEMS "Libs" "Requires" "Cflags")
            set(line "")
            if("${contents}" MATCHES "\n${item}: *([^\n]*)")
                string(APPEND line " ${CMAKE_MATCH_1}")
            endif()
            if("${contents}" MATCHES "\n${item}\\.private: *([^\n]*)")
                string(APPEND line " ${CMAKE_MATCH_1}")
            endif()

            string(REGEX REPLACE "\n${item}(\\.private)?:[^\n]*" "" contents "${contents}")
            if(NOT "${line}" STREQUAL "")
                string(APPEND contents "${item}:${line}\n")
            endif()
        endforeach()
    endif()

    if(contents MATCHES "\nLibs: *([^\n]*)")
        set(libs "${CMAKE_MATCH_1}")
        if(libs MATCHES [[;]])
            # 假设 ';' 仅来自 CMake 列表。可考虑作为参数控制。
            string(REPLACE ";" " " no_lists "${libs}")
            string(REPLACE "${libs}" "${no_lists}" contents "${contents}")
            set(libs "${no_lists}")
        endif()

        separate_arguments(libs_list UNIX_COMMAND "${libs}")
        set(skip_next 0)
        set(libs_filtered "")
        foreach(item IN LISTS libs_list)
            if(skip_next)
                set(skip_next 0)
                continue()
            elseif(item MATCHES "^(-l|-L)?optimized\$")
                string(COMPARE EQUAL "${arg_config}" "DEBUG" skip_next)
                continue()
            elseif(item MATCHES "^(-l|-L)?debug\$")
                string(COMPARE EQUAL "${arg_config}" "RELEASE" skip_next)
                continue()
            elseif(item MATCHES "^(-l|-L)?general\$")
                continue()
            endif()
            if(item MATCHES [[.[\$]| ]] AND NOT item MATCHES [["]])
                set(item "\"${item}\"")
            else()
                set(quoted "\"${item}\"")
                string(FIND " ${libs} " " ${quoted} " index)
                if(NOT index STREQUAL "-1")
                    set(item "${quoted}")
                endif()
            endif()
            list(APPEND libs_filtered "${item}")
        endforeach()
        list(JOIN libs_filtered " " libs_filtered)
        string(REPLACE "${libs}" "${libs_filtered}" contents "${contents}")
        set(libs "${libs_filtered}")

        if(libs MATCHES "[^ ]*-NOTFOUND")
            message(WARNING "${file} 出错: 'Libs' 引用了一个缺失的库:\n...${CMAKE_MATCH_0}")
        endif()
        if(libs MATCHES "[^\n]*::[^\n ]*")
            message(WARNING "${file} 出错: 'Libs' 引用了一个 CMake target:\n...${CMAKE_MATCH_0}")
        endif()
    endif()

    # 对以 `${blah}` 开头的 -L、-I 和 -l 路径加引号
    # 这在 "Libs" 中已经处理过了，但在其他行中可能还有额外的出现。
    string(REGEX REPLACE "([ =])(-[LIl]\\\${[^}]*}[^ ;\n\t]*)" [[\1"\2"]] contents "${contents}")

    set("${arg_variable}" "${contents}" PARENT_SCOPE)
endfunction()

function(z_vcpkg_fixup_pkgconfig_check_files arg_file arg_config)
    set(path_suffix_DEBUG /debug)
    set(path_suffix_RELEASE "")

    z_vcpkg_setup_pkgconfig_path(CONFIG "${arg_config}")

    # 首先确保包及其依赖项一切正常
    cmake_path(GET arg_file STEM LAST_ONLY package_name)
    debug_message("正在检查包 (${arg_config}): ${package_name}")
    execute_process(
        COMMAND "${PKGCONFIG}" --print-errors --exists "${package_name}"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
        RESULT_VARIABLE error_var
        OUTPUT_VARIABLE output
        ERROR_VARIABLE  output
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_STRIP_TRAILING_WHITESPACE
    )
    if(NOT "${error_var}" EQUAL "0")
        message(FATAL_ERROR "${PKGCONFIG} --exists ${package_name} 失败，错误码: ${error_var}
    ENV{PKG_CONFIG_PATH}: \"$ENV{PKG_CONFIG_PATH}\"
    输出: ${output}"
        )
    else()
        debug_message("pkg-config --exists ${package_name} 输出: ${output}")
    endif()

    z_vcpkg_restore_pkgconfig_path()
endfunction()

function(vcpkg_fixup_pkgconfig)
    cmake_parse_arguments(PARSE_ARGV 0 arg 
        "SKIP_CHECK"
        ""
        "RELEASE_FILES;DEBUG_FILES;SYSTEM_LIBRARIES;SYSTEM_PACKAGES;IGNORE_FLAGS"
    )

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} 被传递了多余的参数: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    if(DEFINED arg_RELEASE_FILES AND NOT DEFINED arg_DEBUG_FILES)
        message(FATAL_ERROR "如果指定了 RELEASE_FILES，则必须同时指定 DEBUG_FILES。")
    endif()
    if(NOT DEFINED arg_RELEASE_FILES AND DEFINED arg_DEBUG_FILES)
        message(FATAL_ERROR "如果指定了 DEBUG_FILES，则必须同时指定 RELEASE_FILES。")
    endif()

    if(NOT DEFINED arg_RELEASE_FILES)
        file(GLOB_RECURSE arg_RELEASE_FILES "${CURRENT_PACKAGES_DIR}/**/*.pc")
        file(GLOB_RECURSE arg_DEBUG_FILES "${CURRENT_PACKAGES_DIR}/debug/**/*.pc")
        foreach(debug_file IN LISTS arg_DEBUG_FILES)
            vcpkg_list(REMOVE_ITEM arg_RELEASE_FILES "${debug_file}")
        endforeach()
    endif()

    foreach(config IN ITEMS RELEASE DEBUG)
        debug_message("${config} 文件: ${arg_${config}_FILES}")
        if("${VCPKG_BUILD_TYPE}" STREQUAL "release" AND "${config}" STREQUAL "DEBUG")
            continue()
        endif()
        foreach(file IN LISTS "arg_${config}_FILES")
            message(STATUS "正在修复 pkgconfig 文件: ${file}")
            cmake_path(GET file PARENT_PATH pkg_lib_search_path)
            if("${config}" STREQUAL "DEBUG")
                set(relative_pc_path "${CURRENT_PACKAGES_DIR}/debug")
                cmake_path(RELATIVE_PATH relative_pc_path BASE_DIRECTORY "${pkg_lib_search_path}")
            else()
                set(relative_pc_path "${CURRENT_PACKAGES_DIR}")
                cmake_path(RELATIVE_PATH relative_pc_path BASE_DIRECTORY "${pkg_lib_search_path}")
            endif()
            #修正 *.pc 文件
            file(READ "${file}" contents)
            z_vcpkg_fixup_pkgconfig_process_data(contents "${config}" "\${pcfiledir}/${relative_pc_path}")
            file(WRITE "${file}" "${contents}")
        endforeach()

        if(NOT arg_SKIP_CHECK) # 此检查只能在所有文件修正完成后运行！
            vcpkg_find_acquire_program(PKGCONFIG)
            debug_message("使用的 pkg-config 来自: ${PKGCONFIG}")
            foreach(file IN LISTS "arg_${config}_FILES")
                z_vcpkg_fixup_pkgconfig_check_files("${file}" "${config}")
            endforeach()
        endif()
    endforeach()
    debug_message("修复 pkgconfig --- 完成")

    set(Z_VCPKG_FIXUP_PKGCONFIG_CALLED TRUE CACHE INTERNAL "见下文" FORCE)
    # 用于检查此函数是否已被调用的变量！
    # 理论上 vcpkg 可以查找 *.pc 文件并自动调用此函数，
    # 或在检测到 *.pc 文件时检查此函数是否已被调用。
    # vcpkg_fixup_cmake_targets 也是同理。
endfunction()
