function(vcpkg_execute_required_process_repeat)
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "ALLOW_IN_DOWNLOAD_MODE"
        "COUNT;WORKING_DIRECTORY;LOGNAME"
        "COMMAND"
    )

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "${CMAKE_CURRENT_FUNCTION} 被传递了多余的参数: ${arg_UNPARSED_ARGUMENTS}")
    endif()
    foreach(required_arg IN ITEMS COUNT WORKING_DIRECTORY LOGNAME COMMAND)
        if(NOT DEFINED arg_${required_arg})
            message(FATAL_ERROR "必须指定 ${required_arg}。")
        endif()
    endforeach()

    # 同时检查 COUNT 是否为整数
    if(NOT arg_COUNT GREATER_EQUAL "1")
        message(FATAL_ERROR "COUNT (${arg_COUNT}) 必须大于或等于 1。")
    endif()

    if (DEFINED VCPKG_DOWNLOAD_MODE AND NOT arg_ALLOW_IN_DOWNLOAD_MODE)
        message(FATAL_ERROR
[[
此命令不能在下载模式下执行。
正在终止 portfile 执行。
]])
    endif()

    if(X_PORT_PROFILE AND NOT arg_ALLOW_IN_DOWNLOAD_MODE)
        vcpkg_list(PREPEND arg_COMMAND "${CMAKE_COMMAND}" "-E" "time")
    endif()

    set(all_logs "")
    foreach(loop_count RANGE 1 ${arg_COUNT})
        set(out_log "${CURRENT_BUILDTREES_DIR}/${arg_LOGNAME}-out-${loop_count}.log")
        set(err_log "${CURRENT_BUILDTREES_DIR}/${arg_LOGNAME}-out-${loop_count}.log")
        list(APPEND all_logs "${out_log}" "${err_log}")

        vcpkg_execute_in_download_mode(
            COMMAND ${arg_COMMAND}
            OUTPUT_FILE "${out_log}"
            ERROR_FILE "${err_log}"
            RESULT_VARIABLE error_code
            WORKING_DIRECTORY "${arg_WORKING_DIRECTORY}"
        )
        if(error_code EQUAL "0")
            return()
        endif()
    endforeach()

    set(stringified_logs "")
    foreach(log IN LISTS all_logs)
        if(NOT EXISTS "${log}")
            continue()
        endif()
        file(SIZE "${log}" log_size)
        if(NOT log_size EQUAL "0")
            file(TO_NATIVE_PATH "${log}" native_log)
            string(APPEND stringified_logs "    ${native_log}\n")
        endif()
    endforeach()

    z_vcpkg_prettify_command_line(pretty_command ${arg_COMMAND})
    message(FATAL_ERROR
        "  命令失败: ${pretty_command}\n"
        "  工作目录: ${arg_WORKING_DIRECTORY}\n"
        "  有关更多信息，请查看日志:\n"
        "${stringified_logs}"
    )
endfunction()
