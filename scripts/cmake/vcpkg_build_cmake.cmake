function(vcpkg_build_cmake)
    cmake_parse_arguments(PARSE_ARGV 0 "arg"
        "DISABLE_PARALLEL;ADD_BIN_TO_PATH"
        "TARGET;LOGFILE_ROOT"
        ""
    )

    if(Z_VCPKG_CMAKE_BUILD_GUARD)
        message(FATAL_ERROR "${PORT} 端口已依赖 vcpkg-cmake；不支持在同一端口中同时使用 vcpkg-cmake 和 vcpkg_build_cmake。")
    endif()

    if(NOT DEFINED arg_LOGFILE_ROOT)
        set(arg_LOGFILE_ROOT "build")
    endif()

    vcpkg_list(SET build_param)
    vcpkg_list(SET parallel_param)
    vcpkg_list(SET no_parallel_param)

    if("${Z_VCPKG_CMAKE_GENERATOR}" STREQUAL "Ninja")
        vcpkg_list(SET build_param "-v") # 详细输出
        vcpkg_list(SET parallel_param "-j${VCPKG_CONCURRENCY}")
        vcpkg_list(SET no_parallel_param "-j1")
    elseif("${Z_VCPKG_CMAKE_GENERATOR}" MATCHES "^Visual Studio")
        vcpkg_list(SET build_param
            "/p:VCPkgLocalAppDataDisabled=true"
            "/p:UseIntelMKL=No"
        )
        vcpkg_list(SET parallel_param "/m")
    elseif("${Z_VCPKG_CMAKE_GENERATOR}" STREQUAL "NMake Makefiles")
        # 当前没有为 nmake 构建添加任何选项
    elseif(Z_VCPKG_CMAKE_GENERATOR STREQUAL "Unix Makefiles")
        vcpkg_list(SET build_param "VERBOSE=1")
        vcpkg_list(SET parallel_param "-j${VCPKG_CONCURRENCY}")
        vcpkg_list(SET no_parallel_param "")
    elseif(Z_VCPKG_CMAKE_GENERATOR STREQUAL "Xcode")
        vcpkg_list(SET parallel_param -jobs "${VCPKG_CONCURRENCY}")
        vcpkg_list(SET no_parallel_param -jobs 1)
    else()
        message(FATAL_ERROR "无法识别 vcpkg_configure_cmake() 的 GENERATOR 设置。有效的生成器为: Ninja、Visual Studio 和 NMake Makefiles")
    endif()

    vcpkg_list(SET target_param)
    if(arg_TARGET)
        vcpkg_list(SET target_param "--target" "${arg_TARGET}")
    endif()

    foreach(build_type IN ITEMS debug release)
        if(NOT DEFINED VCPKG_BUILD_TYPE OR "${VCPKG_BUILD_TYPE}" STREQUAL "${build_type}")
            if("${build_type}" STREQUAL "debug")
                set(short_build_type "dbg")
                set(config "Debug")
            else()
                set(short_build_type "rel")
                set(config "Release")
            endif()

            message(STATUS "正在构建 ${TARGET_TRIPLET}-${short_build_type}")

            if(arg_ADD_BIN_TO_PATH)
                vcpkg_backup_env_variables(VARS PATH)
                if("${build_type}" STREQUAL "debug")
                    vcpkg_add_to_path(PREPEND "${CURRENT_INSTALLED_DIR}/debug/bin")
                else()
                    vcpkg_add_to_path(PREPEND "${CURRENT_INSTALLED_DIR}/bin")
                endif()
            endif()

            if(arg_DISABLE_PARALLEL)
                vcpkg_execute_build_process(
                    COMMAND
                        "${CMAKE_COMMAND}" --build . --config "${config}" ${target_param}
                        -- ${build_param} ${no_parallel_param}
                    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${short_build_type}"
                    LOGNAME "${arg_LOGFILE_ROOT}-${TARGET_TRIPLET}-${short_build_type}"
                )
            else()
                vcpkg_execute_build_process(
                    COMMAND
                        "${CMAKE_COMMAND}" --build . --config "${config}" ${target_param}
                        -- ${build_param} ${parallel_param}
                    NO_PARALLEL_COMMAND
                        "${CMAKE_COMMAND}" --build . --config "${config}" ${target_param}
                        -- ${build_param} ${no_parallel_param}
                    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${short_build_type}"
                    LOGNAME "${arg_LOGFILE_ROOT}-${TARGET_TRIPLET}-${short_build_type}"
                )
            endif()

            if(arg_ADD_BIN_TO_PATH)
                vcpkg_restore_env_variables(VARS PATH)
            endif()
        endif()
    endforeach()
endfunction()
