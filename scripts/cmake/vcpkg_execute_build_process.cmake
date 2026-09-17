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
            message(WARNING "请确保您的系统有足够的内存。")
            set(log_out "${log_prefix}-out-1.log")
            set(log_err "${log_prefix}-err-1.log")
            list(APPEND all_logs "${log_out}" "${log_err}")

            if(DEFINED arg_NO_PARALLEL_COMMAND)
                message(STATUS "正在不带并行的方式重新构建")
                execute_process(
                    COMMAND ${arg_NO_PARALLEL_COMMAND}
                    WORKING_DIRECTORY "${arg_WORKING_DIRECTORY}"
                    OUTPUT_FILE "${log_out}"
                    ERROR_FILE "${log_err}"
                    RESULT_VARIABLE error_code
                )
            else()
                message(STATUS "正在重新构建")
                execute_process(
                    COMMAND ${arg_COMMAND}
                    WORKING_DIRECTORY "${arg_WORKING_DIRECTORY}"
                    OUTPUT_FILE "${log_out}"
                    ERROR_FILE "${log_err}"
                    RESULT_VARIABLE error_code
                )
            endif()
        elseif(all_contents MATCHES "mt(\\.exe)? : general error c101008d: ")
            # 杀毒软件的变通方案 - 文件偶尔会被锁定导致 mt.exe 失败
            message(STATUS "mt.exe 已失败。这可能是杀毒软件导致的。在构建树文件夹上禁用杀毒软件可能会提高构建速度")
            foreach(iteration RANGE 1 3)
                message(STATUS "因 mt.exe 文件锁定问题，正在重新构建 ${TARGET_TRIPLET}-${SHORT_BUILDTYPE}。第 ${iteration} 次尝试")

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
            "  命令失败: ${pretty_command}\n"
            "  工作目录: ${arg_WORKING_DIRECTORY}\n"
            "  有关更多信息，请查看日志:\n"
            "${stringified_logs}"
        )
    endif()
endfunction()
