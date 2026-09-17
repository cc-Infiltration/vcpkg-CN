function(vcpkg_configure_qmake)
    # 解析参数，使得 COMMAND 选项参数中的分号不会被擦除
    cmake_parse_arguments(PARSE_ARGV 0 arg
        ""
        "SOURCE_PATH"
        "OPTIONS;OPTIONS_RELEASE;OPTIONS_DEBUG;BUILD_OPTIONS;BUILD_OPTIONS_RELEASE;BUILD_OPTIONS_DEBUG"
    )

    # 查找 qmake 可执行文件
    find_program(qmake_executable NAMES qmake PATHS "${CURRENT_HOST_INSTALLED_DIR}/tools/qt5/bin" NO_DEFAULT_PATH)

    if(NOT qmake_executable)
        message(FATAL_ERROR "vcpkg_configure_qmake: 无法找到 qmake。")
    endif()

    z_vcpkg_get_cmake_vars(cmake_vars_file)
    include("${cmake_vars_file}")

    function(qmake_append_program var qmake_var value)
        get_filename_component(prog "${value}" NAME)
        # QMake 假定所有程序都在 PATH 中？
        vcpkg_list(APPEND ${var} "${qmake_var}=${prog}")
        find_program(${qmake_var} NAMES "${prog}")
        cmake_path(COMPARE "${${qmake_var}}" EQUAL "${value}" correct_prog_on_path)
        if(NOT correct_prog_on_path AND NOT "${value}" MATCHES "|:")
            message(FATAL_ERROR "检测到路径不匹配: '${qmake_var}'。'${value}' 与 '${${qmake_var}}' 不相同。请更正您的 PATH！")
        endif()
        unset(${qmake_var})
        unset(${qmake_var} CACHE)
        set(${var} "${${var}}" PARENT_SCOPE)
    endfunction()
    # 设置构建工具
    set(qmake_build_tools "")
    qmake_append_program(qmake_build_tools "QMAKE_CC" "${VCPKG_DETECTED_CMAKE_C_COMPILER}")
    qmake_append_program(qmake_build_tools "QMAKE_CXX" "${VCPKG_DETECTED_CMAKE_CXX_COMPILER}")
    qmake_append_program(qmake_build_tools "QMAKE_AR" "${VCPKG_DETECTED_CMAKE_AR}")
    qmake_append_program(qmake_build_tools "QMAKE_RANLIB" "${VCPKG_DETECTED_CMAKE_RANLIB}")
    qmake_append_program(qmake_build_tools "QMAKE_STRIP" "${VCPKG_DETECTED_CMAKE_STRIP}")
    qmake_append_program(qmake_build_tools "QMAKE_NM" "${VCPKG_DETECTED_CMAKE_NM}")
    qmake_append_program(qmake_build_tools "QMAKE_RC" "${VCPKG_DETECTED_CMAKE_RC_COMPILER}")
    qmake_append_program(qmake_build_tools "QMAKE_MT" "${VCPKG_DETECTED_CMAKE_MT}")
    if(NOT VCPKG_TARGET_IS_WINDOWS OR VCPKG_DETECTED_CMAKE_AR MATCHES "ar$")
        vcpkg_list(APPEND qmake_build_tools "QMAKE_AR+=qc")
    endif()
    if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
        qmake_append_program(qmake_build_tools "QMAKE_LIB" "${VCPKG_DETECTED_CMAKE_AR}")
        qmake_append_program(qmake_build_tools "QMAKE_LINK" "${VCPKG_DETECTED_CMAKE_LINKER}")
    else()
        qmake_append_program(qmake_build_tools "QMAKE_LINK" "${VCPKG_DETECTED_CMAKE_CXX_COMPILER}")
        qmake_append_program(qmake_build_tools "QMAKE_LINK_SHLIB" "${VCPKG_DETECTED_CMAKE_CXX_COMPILER}")
        qmake_append_program(qmake_build_tools "QMAKE_LINK_C" "${VCPKG_DETECTED_CMAKE_C_COMPILER}")
        qmake_append_program(qmake_build_tools "QMAKE_LINK_C_SHLIB" "${VCPKG_DETECTED_CMAKE_C_COMPILER}")
    endif()
    set(qmake_comp_flags "")
    macro(qmake_add_flags qmake_var operation flags)
        string(STRIP "${flags}" striped_flags)
        if(striped_flags)
            vcpkg_list(APPEND qmake_comp_flags "${qmake_var}${operation}${striped_flags}")
        endif()
    endmacro()

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        vcpkg_list(APPEND arg_OPTIONS "CONFIG-=shared" "CONFIG*=static")
    else()
        vcpkg_list(APPEND arg_OPTIONS "CONFIG-=static" "CONFIG*=shared")
    endif()
    vcpkg_list(APPEND arg_OPTIONS "CONFIG*=force_debug_info")

    if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_CRT_LINKAGE STREQUAL "static")
        vcpkg_list(APPEND arg_OPTIONS "CONFIG*=static_runtime")
    endif()

    if(DEFINED VCPKG_OSX_DEPLOYMENT_TARGET)
        set(ENV{QMAKE_MACOSX_DEPLOYMENT_TARGET} "${VCPKG_OSX_DEPLOYMENT_TARGET}")
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        z_vcpkg_setup_pkgconfig_path(CONFIG RELEASE)

        set(current_binary_dir "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")

        # 清理构建目录
        file(REMOVE_RECURSE "${current_binary_dir}")

        configure_file("${CURRENT_INSTALLED_DIR}/tools/qt5/qt_release.conf" "${current_binary_dir}/qt.conf")

        message(STATUS "正在配置 ${TARGET_TRIPLET}-rel")
        file(MAKE_DIRECTORY "${current_binary_dir}")

        qmake_add_flags("QMAKE_LIBS" "+=" "${VCPKG_DETECTED_CMAKE_C_STANDARD_LIBRARIES} ${VCPKG_DETECTED_CMAKE_CXX_STANDARD_LIBRARIES}")
        qmake_add_flags("QMAKE_RC" "+=" "${VCPKG_DETECTED_CMAKE_RC_FLAGS_RELEASE}")
        qmake_add_flags("QMAKE_CFLAGS_RELEASE" "+=" "${VCPKG_DETECTED_CMAKE_C_FLAGS_RELEASE}")
        qmake_add_flags("QMAKE_CXXFLAGS_RELEASE" "+=" "${VCPKG_DETECTED_CMAKE_CXX_FLAGS_RELEASE}")
        qmake_add_flags("QMAKE_LFLAGS" "+=" "${VCPKG_DETECTED_CMAKE_SHARED_LINKER_FLAGS_RELEASE}")
        qmake_add_flags("QMAKE_LFLAGS_SHLIB" "+=" "${VCPKG_DETECTED_CMAKE_SHARED_LINKER_FLAGS_RELEASE}")
        qmake_add_flags("QMAKE_LFLAGS_PLUGIN" "+=" "${VCPKG_DETECTED_CMAKE_MODULE_LINKER_FLAGS_RELEASE}")
        qmake_add_flags("QMAKE_LIBFLAGS_RELEASE" "+=" "${VCPKG_DETECTED_CMAKE_STATIC_LINKER_FLAGS_RELEASE}")

        vcpkg_list(SET build_opt_param)
        if(DEFINED arg_BUILD_OPTIONS OR DEFINED arg_BUILD_OPTIONS_RELEASE)
            vcpkg_list(SET build_opt_param -- ${arg_BUILD_OPTIONS} ${arg_BUILD_OPTIONS_RELEASE})
        endif()

        vcpkg_execute_required_process(
            COMMAND "${qmake_executable}" CONFIG-=debug CONFIG+=release ${qmake_build_tools} ${qmake_comp_flags}
                    ${arg_OPTIONS} ${arg_OPTIONS_RELEASE} ${arg_SOURCE_PATH}
                    -qtconf "${current_binary_dir}/qt.conf"
                    ${build_opt_param}
            WORKING_DIRECTORY "${current_binary_dir}"
            LOGNAME "config-${TARGET_TRIPLET}-rel"
            SAVE_LOG_FILES config.log
        )
        message(STATUS "配置 ${TARGET_TRIPLET}-rel 完成")
        if(EXISTS "${current_binary_dir}/config.log")
            file(REMOVE "${CURRENT_BUILDTREES_DIR}/internal-config-${TARGET_TRIPLET}-rel.log")
            file(RENAME "${current_binary_dir}/config.log" "${CURRENT_BUILDTREES_DIR}/internal-config-${TARGET_TRIPLET}-rel.log")
        endif()

        z_vcpkg_restore_pkgconfig_path()
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        z_vcpkg_setup_pkgconfig_path(CONFIG DEBUG)

        set(current_binary_dir "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")

        # 清理构建目录
        file(REMOVE_RECURSE "${current_binary_dir}")

        configure_file("${CURRENT_INSTALLED_DIR}/tools/qt5/qt_debug.conf" "${current_binary_dir}/qt.conf")

        message(STATUS "正在配置 ${TARGET_TRIPLET}-dbg")
        file(MAKE_DIRECTORY "${current_binary_dir}")

        set(qmake_comp_flags "")
        qmake_add_flags("QMAKE_LIBS" "+=" "${VCPKG_DETECTED_CMAKE_C_STANDARD_LIBRARIES} ${VCPKG_DETECTED_CMAKE_CXX_STANDARD_LIBRARIES}")
        qmake_add_flags("QMAKE_RC" "+=" "${VCPKG_DETECTED_CMAKE_RC_FLAGS_DEBUG}")
        qmake_add_flags("QMAKE_CFLAGS_DEBUG" "+=" "${VCPKG_DETECTED_CMAKE_C_FLAGS_DEBUG}")
        qmake_add_flags("QMAKE_CXXFLAGS_DEBUG" "+=" "${VCPKG_DETECTED_CMAKE_CXX_FLAGS_DEBUG}")
        qmake_add_flags("QMAKE_LFLAGS" "+=" "${VCPKG_DETECTED_CMAKE_SHARED_LINKER_FLAGS_DEBUG}")
        qmake_add_flags("QMAKE_LFLAGS_SHLIB" "+=" "${VCPKG_DETECTED_CMAKE_SHARED_LINKER_FLAGS_DEBUG}")
        qmake_add_flags("QMAKE_LFLAGS_PLUGIN" "+=" "${VCPKG_DETECTED_CMAKE_MODULE_LINKER_FLAGS_DEBUG}")
        qmake_add_flags("QMAKE_LIBFLAGS_DEBUG" "+=" "${VCPKG_DETECTED_CMAKE_STATIC_LINKER_FLAGS_DEBUG}")

        vcpkg_list(SET build_opt_param)
        if(DEFINED arg_BUILD_OPTIONS OR DEFINED arg_BUILD_OPTIONS_DEBUG)
            vcpkg_list(SET build_opt_param -- ${arg_BUILD_OPTIONS} ${arg_BUILD_OPTIONS_DEBUG})
        endif()
        vcpkg_execute_required_process(
            COMMAND "${qmake_executable}" CONFIG-=release CONFIG+=debug ${qmake_build_tools} ${qmake_comp_flags}
                    ${arg_OPTIONS} ${arg_OPTIONS_DEBUG} ${arg_SOURCE_PATH}
                    -qtconf "${current_binary_dir}/qt.conf"
                    ${build_opt_param}
            WORKING_DIRECTORY "${current_binary_dir}"
            LOGNAME "config-${TARGET_TRIPLET}-dbg"
            SAVE_LOG_FILES config.log
        )
        message(STATUS "配置 ${TARGET_TRIPLET}-dbg 完成")
        if(EXISTS "${current_binary_dir}/config.log")
            file(REMOVE "${CURRENT_BUILDTREES_DIR}/internal-config-${TARGET_TRIPLET}-dbg.log")
            file(RENAME "${current_binary_dir}/config.log" "${CURRENT_BUILDTREES_DIR}/internal-config-${TARGET_TRIPLET}-dbg.log")
        endif()
        
        z_vcpkg_restore_pkgconfig_path()
    endif()

endfunction()
