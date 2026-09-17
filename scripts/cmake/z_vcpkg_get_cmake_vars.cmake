function(z_vcpkg_get_cmake_vars out_file)
    cmake_parse_arguments(PARSE_ARGV 1 arg "" "" "")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} 被传入了多余的参数：${arg_UNPARSED_ARGUMENTS}")
    endif()

    if(DEFINED VCPKG_BUILD_TYPE)
        set(cmake_vars_file "${CURRENT_BUILDTREES_DIR}/cmake-vars-${TARGET_TRIPLET}-${VCPKG_BUILD_TYPE}.cmake.log")
        set(cache_var "Z_VCPKG_GET_CMAKE_VARS_FILE_${VCPKG_BUILD_TYPE}")
    else()
        set(cmake_vars_file "${CURRENT_BUILDTREES_DIR}/cmake-vars-${TARGET_TRIPLET}.cmake.log")
        set(cache_var Z_VCPKG_GET_CMAKE_VARS_FILE)
    endif()
    if(NOT DEFINED CACHE{${cache_var}})
        set(${cache_var}  "${cmake_vars_file}"
            CACHE PATH "用于包含生成的项目中 CMake 变量的文件路径。")
        vcpkg_configure_cmake(
            SOURCE_PATH "${SCRIPTS}/get_cmake_vars"
            OPTIONS_DEBUG "-DVCPKG_OUTPUT_FILE:PATH=${CURRENT_BUILDTREES_DIR}/cmake-vars-${TARGET_TRIPLET}-dbg.cmake.log"
            OPTIONS_RELEASE "-DVCPKG_OUTPUT_FILE:PATH=${CURRENT_BUILDTREES_DIR}/cmake-vars-${TARGET_TRIPLET}-rel.cmake.log"
            PREFER_NINJA
            LOGNAME get-cmake-vars-${TARGET_TRIPLET}
            Z_GET_CMAKE_VARS_USAGE # 忽略 vcpkg_cmake_configure，保持静默，不设置变量...
        )

        set(include_string "")
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
            string(APPEND include_string "include(\"\${CMAKE_CURRENT_LIST_DIR}/cmake-vars-${TARGET_TRIPLET}-rel.cmake.log\")\n")
        endif()
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
            string(APPEND include_string "include(\"\${CMAKE_CURRENT_LIST_DIR}/cmake-vars-${TARGET_TRIPLET}-dbg.cmake.log\")\n")
        endif()
        file(WRITE "${cmake_vars_file}" "${include_string}")
    endif()

    set("${out_file}" "${${cache_var}}" PARENT_SCOPE)
endfunction()
