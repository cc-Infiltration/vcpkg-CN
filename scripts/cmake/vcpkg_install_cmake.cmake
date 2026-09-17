function(vcpkg_install_cmake)
    if(Z_VCPKG_CMAKE_INSTALL_GUARD)
        message(FATAL_ERROR "${PORT} 端口已依赖于 vcpkg-cmake；在同一端口中同时使用 vcpkg-cmake 和 vcpkg_install_cmake 不受支持。")
    endif()

    cmake_parse_arguments(PARSE_ARGV 0 "arg" "DISABLE_PARALLEL;ADD_BIN_TO_PATH" "" "")
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "vcpkg_cmake_install 被传递了多余的参数: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    vcpkg_list(SET params)
    foreach(arg IN ITEMS DISABLE_PARALLEL ADD_BIN_TO_PATH)
        if(arg_${arg})
            vcpkg_list(APPEND params "${arg}")
        endif()
    endforeach()

    vcpkg_build_cmake(Z_VCPKG_DISABLE_DEPRECATION MESSAGE
        ${params}
        LOGFILE_ROOT install
        TARGET install
    )
endfunction()
