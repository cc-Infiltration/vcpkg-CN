function(z_vcpkg_install_gn_get_target_type out_var)
    cmake_parse_arguments(PARSE_ARGV 1 "arg" "" "SOURCE_PATH;BUILD_DIR;TARGET" "")
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "内部错误: get_target_type 被传递了多余的参数: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    execute_process(
        COMMAND "${GN}" desc "${arg_BUILD_DIR}" "${arg_TARGET}"
        WORKING_DIRECTORY "${arg_SOURCE_PATH}"
        OUTPUT_VARIABLE output
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    if(output MATCHES [[type: ([A-Za-z0-9_]+)]])
        set("${out_var}" "${CMAKE_MATCH_1}" PARENT_SCOPE)
    else()
        message(FATAL_ERROR "`gn desc` 返回了无效结果: ${output}")
    endif()
endfunction()

function(z_vcpkg_install_gn_get_desc out_var)
    cmake_parse_arguments(PARSE_ARGV 1 "arg" "" "SOURCE_PATH;BUILD_DIR;TARGET;WHAT_TO_DISPLAY" "")
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "内部错误: get_desc 被传递了多余的参数: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    execute_process(
        COMMAND "${GN}" desc "${arg_BUILD_DIR}" "${arg_TARGET}" "${arg_WHAT_TO_DISPLAY}"
        WORKING_DIRECTORY "${arg_SOURCE_PATH}"
        OUTPUT_VARIABLE output
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    string(REPLACE ";" "\\;" output "${output}")
    string(REGEX REPLACE "\n|(\r\n)" ";" output "${output}")
    set("${out_var}" "${output}" PARENT_SCOPE)
endfunction()

function(z_vcpkg_install_gn_install)
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "" "SOURCE_PATH;BUILD_DIR;INSTALL_DIR" "TARGETS")
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "内部错误: install 被传递了多余的参数: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    foreach(target IN LISTS arg_TARGETS)
        # GN 目标必须以 // 开头
        z_vcpkg_install_gn_get_desc(outputs
            SOURCE_PATH "${arg_SOURCE_PATH}"
            BUILD_DIR "${arg_BUILD_DIR}"
            TARGET "//${target}"
            WHAT_TO_DISPLAY outputs
        )
        z_vcpkg_install_gn_get_target_type(target_type
            SOURCE_PATH "${arg_SOURCE_PATH}"
            BUILD_DIR "${arg_BUILD_DIR}"
            TARGET "//${target}"
        )

        foreach(output IN LISTS outputs)
            if(output MATCHES "^//")
                # 相对路径（例如 //out/Release/target.lib）
                string(REGEX REPLACE "^//" "${arg_SOURCE_PATH}/" output "${output}")
            elseif(output MATCHES "^/" AND CMAKE_HOST_WIN32)
                # 绝对路径（例如 /C:/path/to/target.lib）
                string(REGEX REPLACE "^/" "" output "${output}")
            endif()

            if(NOT EXISTS "${output}")
                message(WARNING "目标 `${target}` 的输出不存在: ${output}。")
                continue()
            endif()

            if(target_type STREQUAL "executable")
                file(INSTALL "${output}" DESTINATION "${arg_INSTALL_DIR}/tools")
            elseif(output MATCHES "(\\.dll|\\.pdb)$")
                file(INSTALL "${output}" DESTINATION "${arg_INSTALL_DIR}/bin")
            else()
                file(INSTALL "${output}" DESTINATION "${arg_INSTALL_DIR}/lib")
            endif()
        endforeach()
    endforeach()
endfunction()

function(vcpkg_install_gn)
    if(Z_VCPKG_GN_INSTALL_GUARD)
        message(FATAL_ERROR "${PORT} 端口已依赖于 vcpkg-gn；在同一端口中同时使用 vcpkg-gn 和 vcpkg_install_gn 不受支持。")
    else()
        message("${Z_VCPKG_BACKCOMPAT_MESSAGE_LEVEL}" "此函数 'vcpkg_install_gn' 已过时。请使用 'vcpkg-gn' 端口中的 'vcpkg_gn_install'。")
    endif()

    cmake_parse_arguments(PARSE_ARGV 0 arg "" "SOURCE_PATH" "TARGETS")
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "vcpkg_install_gn 被传递了多余的参数: ${arg_UNPARSED_ARGUMENTS}")
    endif()
    if(NOT DEFINED arg_SOURCE_PATH)
        message(FATAL_ERROR "必须指定 SOURCE_PATH。")
    endif()

    vcpkg_build_ninja(TARGETS ${arg_TARGETS})

    vcpkg_find_acquire_program(GN)

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        z_vcpkg_install_gn_install(
            SOURCE_PATH "${arg_SOURCE_PATH}"
            BUILD_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
            INSTALL_DIR "${CURRENT_PACKAGES_DIR}/debug"
            TARGETS ${arg_TARGETS}
        )
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        z_vcpkg_install_gn_install(
            SOURCE_PATH "${arg_SOURCE_PATH}"
            BUILD_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
            INSTALL_DIR "${CURRENT_PACKAGES_DIR}"
            TARGETS ${arg_TARGETS}
        )
    endif()
endfunction()
