set(Z_VCPKG_EXECUTE_BUILD_PROCESS_RETRY_ERROR_MESSAGES
    "LINK : fatal error LNK1102:"
    " fatal error C1060: "
    # 链接器在执行期间内存不足。我们将禁用并行后重试一次。
    "LINK : fatal error LNK1318:"
    "LINK : fatal error LNK1104:"
    "LINK : fatal error LNK1201:"
    "ld terminated with signal 9"
    "Killed signal terminated program"
    # 多个线程同时使用同一目录会导致冲突，将重试。
    "Cannot create parent directory"
    "Cannot write file"
    # 多个线程导致创建文件夹和文件夹中创建文件的顺序错误
    "Can't open"
    # `make install` 可能因并发而失败，特别是在 osx 上的 `mkdir`。
    "mkdir [^:]*: File exists"
)
list(JOIN Z_VCPKG_EXECUTE_BUILD_PROCESS_RETRY_ERROR_MESSAGES "|" Z_VCPKG_EXECUTE_BUILD_PROCESS_RETRY_ERROR_MESSAGES)

function(vcpkg_execute_build_process)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "WORKING_DIRECTORY;LOGNAME" "COMMAND;NO_PARALLEL_COMMAND")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "${CMAKE_CURRENT_FUNCTION} 传入了多余的参数：${arg_UNPARSED_ARGUMENTS}")
    endif()
    foreach(required_arg IN ITEMS WORKING_DIRECTORY COMMAND)
        if(NOT DEFINED arg_${required_arg})
            message(FATAL_ERROR "必须指定 ${required_arg}。")
        endif()
    endforeach()

    if(NOT DEFINED arg_LOGNAME)
        message(WARNING "应指定 LOGNAME。")
        set(arg_LOGNAME "build")
    endif()

    set(log_prefix "${CURRENT_BUILDTREES_DIR}/${arg_LOGNAME}")
    set(log_out "${log_prefix}-out.log")
    set(log_err "${log_prefix}-err.log")
    set(all_logs "${log_out}" "${log_err}")

    if(X_PORT_PROFILE)
        vcpkg_list(PREPEND arg_COMMAND "${CMAKE_COMMAND}" "-E" "time")
        if(DEFINED arg_NO_PARALLEL_COMMAND)
            vcpkg_list(PREPEND arg_NO_PARALLEL_COMMAND "${CMAKE_COMMAND}" "-E" "time")
        endif()
    endif()

    execute_process(
        COMMAND ${arg_COMMAND}
        WORKING_DIRECTORY "${arg_WORKING_DIRECTORY}"
        OUTPUT_FILE "${log_out}"
        ERROR_FILE "${log_err}"
        RESULT_VARIABLE error_code
    )
    if (NOT error_code MATCHES "^-?[0-9]+$")
        list(JOIN arg_COMMAND " " command)
        message(FATAL_ERROR "在工作目录 \"${arg_WORKING_DIRECTORY}\" 中执行命令 \"${command}\" 失败：${error_code}")
    endif()
    if(NOT error_code EQUAL "0")
        file(READ "${log_out}" out_contents)
        file(READ "${log_err}" err_contents)
        set(all_contents "${out_contents}${err_contents}")
        if(all_contents MATCHES "${Z_VCPKG_EXECUTE_BUILD_PROCESS_RETRY_ERROR_MESSAGES}")
            message(WARNING "Please ensure your system has sufficient memory.")
            set(log_out "${log_prefix}-out-1.log")
            set(log_err "${log_prefix}-err-1.log")
            list(APPEND all_logs "${log_out}" "${log_err}")

            if(DEFINED arg_NO_PARALLEL_COMMAND)
                message(STATUS "Restarting build without parallelism")
                execute_process(
                    COMMAND ${arg_NO_PARALLEL_COMMAND}
                    WORKING_DIRECTORY "${arg_WORKING_DIRECTORY}"
                    OUTPUT_FILE "${log_out}"
                    ERROR_FILE "${log_err}"
                    RESULT_VARIABLE error_code
                )
            else()
                message(STATUS "Restarting build")
                execute_process(
                    COMMAND ${arg_COMMAND}
                    WORKING_DIRECTORY "${arg_WORKING_DIRECTORY}"
                    OUTPUT_FILE "${log_out}"
                    ERROR_FILE "${log_err}"
                    RESULT_VARIABLE error_code
                )
            endif()
        elseif(all_contents MATCHES "mt(\\.exe)? : general error c101008d: ")
            # Antivirus workaround - occasionally files are locked and cause mt.exe to fail
            message(STATUS "mt.exe has failed. This may be the result of anti-virus. Disabling anti-virus on the buildtree folder may improve build speed")
            foreach(iteration RANGE 1 3)
                message(STATUS "Restarting Build ${TARGET_TRIPLET}-${SHORT_BUILDTYPE} because of mt.exe file locking issue. Iteration: ${iteration}")

                set(log_out "${log_prefix}-out-${iteration}.log")
                set(log_err "${log_prefix}-err-${iteration}.log")
                list(APPEND all_logs "${log_out}" "${log_err}")
                execute_process(
                    COMMAND ${arg_COMMAND}
                    WORKING_DIRECTORY "${arg_WORKING_DIRECTORY}"
                    OUTPUT_FILE "${log_out}"
                    ERROR_FILE "${log_err}"
                    RESULT_VARIABLE error_code
                )

                if(error_code EQUAL "0")
                    break()
                endif()

                file(READ "${log_out}" out_contents)
                file(READ "${log_err}" err_contents)
                set(all_contents "${out_contents}${err_contents}")
                if(NOT all_contents MATCHES "mt : general error c101008d: ")
                    break()
                endif()
            endforeach()
        endif()
    endif()

    if(NOT error_code EQUAL "0")
        set(stringified_logs "")
        foreach(log IN LISTS all_logs)
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
            "  Command failed: ${pretty_command}\n"
            "  Working Directory: ${arg_WORKING_DIRECTORY}\n"
            "  See logs for more information:\n"
            "${stringified_logs}"
        )
    endif()
endfunction()
