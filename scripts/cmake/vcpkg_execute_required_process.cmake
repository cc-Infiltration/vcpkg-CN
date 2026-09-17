function(vcpkg_execute_required_process)
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "ALLOW_IN_DOWNLOAD_MODE;OUTPUT_STRIP_TRAILING_WHITESPACE;ERROR_STRIP_TRAILING_WHITESPACE"
        "WORKING_DIRECTORY;LOGNAME;TIMEOUT;OUTPUT_VARIABLE;ERROR_VARIABLE"
        "COMMAND;SAVE_LOG_FILES"
    )

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "${CMAKE_CURRENT_FUNCTION} 被传递了多余的参数: ${arg_UNPARSED_ARGUMENTS}")
    endif()
    foreach(required_arg IN ITEMS WORKING_DIRECTORY COMMAND)
        if(NOT DEFINED arg_${required_arg})
            message(FATAL_ERROR "必须指定 ${required_arg}。")
        endif()
    endforeach()

    if(NOT DEFINED arg_LOGNAME)
        message(WARNING "应指定 LOGNAME。")
        set(arg_LOGNAME "required")
    endif()

    if (VCPKG_DOWNLOAD_MODE AND NOT arg_ALLOW_IN_DOWNLOAD_MODE)
        message(FATAL_ERROR
[[
此命令不能在下载模式下执行。
正在终止 portfile 执行。
]])
    endif()

    set(timeout_param "")
    if(DEFINED arg_TIMEOUT)
        set(timeout_param TIMEOUT "${arg_TIMEOUT}")
    endif()

    set(log_out "${CURRENT_BUILDTREES_DIR}/${arg_LOGNAME}-out.log")
    set(log_err "${CURRENT_BUILDTREES_DIR}/${arg_LOGNAME}-err.log")
    set(output_param OUTPUT_FILE "${log_out}")
    set(error_param ERROR_FILE "${log_err}")
    set(output_and_error_same OFF)
    if(DEFINED arg_OUTPUT_VARIABLE AND DEFINED arg_ERROR_VARIABLE AND arg_OUTPUT_VARIABLE STREQUAL arg_ERROR_VARIABLE)
        set(output_param OUTPUT_VARIABLE out_err_var)
        set(error_param ERROR_VARIABLE out_err_var)
        set(output_and_error_same ON)
    else()
        if(DEFINED arg_OUTPUT_VARIABLE)
            set(output_param OUTPUT_VARIABLE out_var)
        endif()
        if(DEFINED arg_ERROR_VARIABLE)
            set(error_param ERROR_VARIABLE err_var)
        endif()
    endif()
    if(arg_OUTPUT_STRIP_TRAILING_WHITESPACE)
        list(APPEND output_param OUTPUT_STRIP_TRAILING_WHITESPACE)
    endif()
    if(arg_ERROR_STRIP_TRAILING_WHITESPACE)
        list(APPEND error_param ERROR_STRIP_TRAILING_WHITESPACE)
    endif()

    if(X_PORT_PROFILE AND NOT arg_ALLOW_IN_DOWNLOAD_MODE)
        vcpkg_list(PREPEND arg_COMMAND "${CMAKE_COMMAND}" "-E" "time")
    endif()

    vcpkg_execute_in_download_mode(
        COMMAND ${arg_COMMAND}
        RESULT_VARIABLE error_code
        WORKING_DIRECTORY "${arg_WORKING_DIRECTORY}"
        ${timeout_param}
        ${output_param}
        ${error_param}
    )

    if(output_and_error_same)
        file(WRITE "${log_out}" "${out_err_var}")
        file(WRITE "${log_err}" "")
    else()
        if(DEFINED arg_OUTPUT_VARIABLE)
            file(WRITE "${log_out}" "${out_var}")
        endif()
        if(DEFINED arg_ERROR_VARIABLE)
            file(WRITE "${log_err}" "${err_var}")
        endif()
    endif()
    vcpkg_list(SET logfiles)
    vcpkg_list(SET logfile_copies)
    set(expect_alias FALSE)
    foreach(item IN LISTS arg_SAVE_LOG_FILES)
        if(expect_alias)
            vcpkg_list(POP_BACK logfile_copies)
            vcpkg_list(APPEND logfile_copies "${CURRENT_BUILDTREES_DIR}/${arg_LOGNAME}-${item}")
            set(expect_alias FALSE)
        elseif(item STREQUAL "ALIAS")
            if(NOT logfiles)
                message(FATAL_ERROR "ALIAS 在没有源文件的情况下使用")
            endif()
            set(expect_alias TRUE)
        else()
            vcpkg_list(APPEND logfiles "${arg_WORKING_DIRECTORY}/${item}")
            cmake_path(GET item FILENAME filename)
            if(NOT filename MATCHES "[.]log\$")
                string(APPEND filename ".log")
            endif()
            vcpkg_list(APPEND logfile_copies "${CURRENT_BUILDTREES_DIR}/${arg_LOGNAME}-${filename}")
        endif()
    endforeach()
    vcpkg_list(SET saved_logs)
    foreach(logfile logfile_copy IN ZIP_LISTS logfiles logfile_copies)
        if(EXISTS "${logfile}")
            configure_file("${logfile}" "${logfile_copy}" COPYONLY)
            vcpkg_list(APPEND saved_logs "${logfile_copy}")
        endif()
    endforeach()
    if(NOT error_code EQUAL 0)
        set(stringified_logs "")
        foreach(log IN LISTS saved_logs ITEMS "${log_out}" "${log_err}")
            if(NOT EXISTS "${log}")
                continue()
            endif()
            file(SIZE "${log}" log_size)
            if(NOT log_size EQUAL "0")
                file(TO_NATIVE_PATH "${log}" native_log)
                string(APPEND stringified_logs "    ${native_log}\n")
                file(APPEND "${Z_VCPKG_ERROR_LOG_COLLECTION_FILE}" "${native_log}\n")
            endif()
        endforeach()

        z_vcpkg_prettify_command_line(pretty_command ${arg_COMMAND})
        message(FATAL_ERROR
            "  命令失败: ${pretty_command}\n"
            "  工作目录: ${arg_WORKING_DIRECTORY}\n"
            "  错误码: ${error_code}\n"
            "  有关更多信息，请查看日志:\n"
            "${stringified_logs}"
        )
    endif()

    # 将输出参数传回调用者的作用域
    if(output_and_error_same)
        z_vcpkg_forward_output_variable(arg_OUTPUT_VARIABLE out_err_var)
        # arg_ERROR_VARIABLE = arg_OUTPUT_VARIABLE，因此无需再次设置
    else()
        z_vcpkg_forward_output_variable(arg_OUTPUT_VARIABLE out_var)
        z_vcpkg_forward_output_variable(arg_ERROR_VARIABLE err_var)
    endif()
endfunction()
