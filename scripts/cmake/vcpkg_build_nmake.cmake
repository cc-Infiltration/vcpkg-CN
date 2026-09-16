function(vcpkg_build_nmake)
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "ADD_BIN_TO_PATH;ENABLE_INSTALL;NO_DEBUG;PREFER_JOM"
        "SOURCE_PATH;PROJECT_SUBPATH;PROJECT_NAME;LOGFILE_ROOT;CL_LANGUAGE"
        "OPTIONS;OPTIONS_RELEASE;OPTIONS_DEBUG;PRERUN_SHELL;PRERUN_SHELL_DEBUG;PRERUN_SHELL_RELEASE;TARGET"
    )
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "${CMAKE_CURRENT_FUNCTION} 收到了多余参数: ${arg_UNPARSED_ARGUMENTS}")
    endif()
    if(NOT DEFINED arg_SOURCE_PATH)
        message(FATAL_ERROR "必须指定 SOURCE_PATH")
    endif()

    if(arg_NO_DEBUG)
        message(WARNING "${CMAKE_CURRENT_FUNCTION} 的 NO_DEBUG 参数已弃用")
    endif()
    if(arg_ADD_BIN_TO_PATH)
        message(WARNING "${CMAKE_CURRENT_FUNCTION} 的 ADD_BIN_TO_PATH 参数已弃用 - 它从未起任何作用")
    endif()

    if(NOT VCPKG_HOST_IS_WINDOWS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} 仅支持 Windows。")
    endif()

    if(NOT DEFINED arg_LOGFILE_ROOT)
        set(arg_LOGFILE_ROOT "build")
    endif()
    if(NOT DEFINED arg_PROJECT_NAME)
        set(arg_PROJECT_NAME makefile.vc)
    endif()

    if(NOT DEFINED arg_TARGET)
        vcpkg_list(SET arg_TARGET all)
    endif()
    if(arg_ENABLE_INSTALL)
        vcpkg_list(APPEND arg_TARGET install)
    endif()

    if(NOT DEFINED arg_CL_LANGUAGE)
        set(arg_CL_LANGUAGE CXX)
    endif()

    find_program(NMAKE nmake REQUIRED)
    get_filename_component(NMAKE_EXE_PATH "${NMAKE}" DIRECTORY)
    # 加载工具链
    z_vcpkg_get_cmake_vars(cmake_vars_file)
    debug_message("Including cmake vars from: ${cmake_vars_file}")
    include("${cmake_vars_file}")
    # 设置所需的环境变量
    set(ENV{PATH} "$ENV{PATH};${NMAKE_EXE_PATH}")
    set(ENV{INCLUDE} "${CURRENT_INSTALLED_DIR}/include;$ENV{INCLUDE}")
    # 设置 make 选项
    vcpkg_list(SET make_opts_base /NOLOGO /G /U /F "${arg_PROJECT_NAME}" ${arg_TARGET})

    if(arg_PREFER_JOM AND VCPKG_CONCURRENCY GREATER "1")
        vcpkg_find_acquire_program(JOM)
        get_filename_component(JOM_EXE_PATH "${JOM}" DIRECTORY)
        vcpkg_add_to_path("${JOM_EXE_PATH}")
        if(arg_CL_LANGUAGE AND "${VCPKG_DETECTED_CMAKE_${arg_CL_LANGUAGE}_COMPILER_ID}" STREQUAL "MSVC")
            string(REGEX REPLACE " [/-]MP[0-9]* " " " VCPKG_DETECTED_CMAKE_${arg_CL_LANGUAGE}_FLAGS_DEBUG " ${VCPKG_DETECTED_CMAKE_${arg_CL_LANGUAGE}_FLAGS_DEBUG} /FS")
            string(REGEX REPLACE " [/-]MP[0-9]* " " " VCPKG_DETECTED_CMAKE_${arg_CL_LANGUAGE}_FLAGS_RELEASE " ${VCPKG_DETECTED_CMAKE_${arg_CL_LANGUAGE}_FLAGS_RELEASE} /FS")
        endif()
    else()
        set(arg_PREFER_JOM FALSE)
    endif()

    # 将子路径添加到工作目录
    if(DEFINED arg_PROJECT_SUBPATH)
        set(project_subpath "/${arg_PROJECT_SUBPATH}")
    else()
        set(project_subpath "")
    endif()

    vcpkg_backup_env_variables(VARS _CL_ _LINK_)
    cmake_path(NATIVE_PATH CURRENT_PACKAGES_DIR NORMALIZE install_dir_native)
    foreach(build_type IN ITEMS debug release)
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL build_type)
            if(build_type STREQUAL "debug")
                # 生成目标目录后缀
                set(short_build_type "-dbg")
                # 添加安装命令和参数
                set(make_opts "${make_opts_base}")
                if (arg_ENABLE_INSTALL)
                    vcpkg_list(APPEND make_opts "INSTALLDIR=${install_dir_native}\\debug")
                endif()
                vcpkg_list(APPEND make_opts ${arg_OPTIONS} ${arg_OPTIONS_DEBUG})
                if(NOT arg_CL_LANGUAGE STREQUAL "NONE")
                    set(ENV{_CL_} "${VCPKG_DETECTED_CMAKE_${arg_CL_LANGUAGE}_FLAGS_DEBUG}")
                endif()
                set(ENV{_LINK_} "${VCPKG_DETECTED_CMAKE_SHARED_LINKER_FLAGS_DEBUG}")

                set(prerun_variable_name arg_PRERUN_SHELL_DEBUG)
            else()
                set(short_build_type "-rel")
                # 添加安装命令和参数
                set(make_opts "${make_opts_base}")
                if (arg_ENABLE_INSTALL)
                    vcpkg_list(APPEND make_opts "INSTALLDIR=${install_dir_native}")
                endif()
                vcpkg_list(APPEND make_opts ${arg_OPTIONS} ${arg_OPTIONS_RELEASE})

                if(NOT arg_CL_LANGUAGE STREQUAL "NONE")
                    set(ENV{_CL_} "${VCPKG_DETECTED_CMAKE_${arg_CL_LANGUAGE}_FLAGS_RELEASE}")
                endif()
                set(ENV{_LINK_} "${VCPKG_DETECTED_CMAKE_SHARED_LINKER_FLAGS_RELEASE}")
                set(prerun_variable_name arg_PRERUN_SHELL_RELEASE)
            endif()

            set(triplet_and_build_type "${TARGET_TRIPLET}${short_build_type}")
            set(object_dir "${CURRENT_BUILDTREES_DIR}/${triplet_and_build_type}")

            file(REMOVE_RECURSE "${object_dir}")
            file(COPY "${arg_SOURCE_PATH}/" DESTINATION "${object_dir}")

            if(DEFINED arg_PRERUN_SHELL)
                message(STATUS "预运行 ${triplet_and_build_type}")
                vcpkg_execute_required_process(
                    COMMAND ${arg_PRERUN_SHELL}
                    WORKING_DIRECTORY "${object_dir}${project_subpath}"
                    LOGNAME "prerun-${triplet_and_build_type}"
                )
            endif()
            if(DEFINED "${prerun_variable_name}")
                message(STATUS "预运行 ${triplet_and_build_type}")
                vcpkg_execute_required_process(
                    COMMAND ${${prerun_variable_name}}
                    WORKING_DIRECTORY "${object_dir}${project_subpath}"
                    LOGNAME "prerun-specific-${triplet_and_build_type}"
                )
            endif()

            if (NOT arg_ENABLE_INSTALL)
                message(STATUS "正在构建 ${triplet_and_build_type}")
            else()
                message(STATUS "正在构建并安装 ${triplet_and_build_type}")
            endif()

            set(run_nmake TRUE)
            set(tool_suffix "")
            if(arg_PREFER_JOM)
                execute_process(
                    COMMAND "${JOM}" /K /J ${VCPKG_CONCURRENCY} ${make_opts}
                    WORKING_DIRECTORY "${object_dir}${project_subpath}"
                    OUTPUT_FILE "${CURRENT_BUILDTREES_DIR}/${arg_LOGFILE_ROOT}-${triplet_and_build_type}-jom-out.log"
                    ERROR_FILE "${CURRENT_BUILDTREES_DIR}/${arg_LOGFILE_ROOT}-${triplet_and_build_type}-jom-err.log"
                    RESULT_VARIABLE error_code
                )
                if(error_code EQUAL "0")
                    set(run_nmake FALSE)
                else()
                    message(STATUS "正在无并行的情况下重新构建")
                    set(tool_suffix "-nmake")
                endif()
            endif()
            if(run_nmake)
                vcpkg_execute_build_process(
                    COMMAND "${NMAKE}" ${make_opts}
                    WORKING_DIRECTORY "${object_dir}${project_subpath}"
                    LOGNAME "${arg_LOGFILE_ROOT}-${triplet_and_build_type}${tool_suffix}"
                )
            endif()

            vcpkg_restore_env_variables(VARS _CL_ _LINK_)
        endif()
    endforeach()
endfunction()
