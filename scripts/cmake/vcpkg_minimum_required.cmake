function(vcpkg_minimum_required)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "VERSION" "")
    if(NOT DEFINED VCPKG_BASE_VERSION)
        message(FATAL_ERROR "您的 vcpkg 可执行文件已过时，与当前的 CMake 脚本不兼容。
    请通过运行 bootstrap-vcpkg 重新获取 vcpkg。"
        )
    endif()
    if(NOT DEFINED arg_VERSION)
        message(FATAL_ERROR "必须指定 VERSION")
    endif()

    set(vcpkg_date_regex "^[12][0-9][0-9][0-9]-[01][0-9]-[0-3][0-9]$")
    if(NOT "${VCPKG_BASE_VERSION}" MATCHES "${vcpkg_date_regex}")
        message(FATAL_ERROR
            "vcpkg 内部错误；VCPKG_BASE_VERSION (${VCPKG_BASE_VERSION}) 不是有效的日期。"
        )
    endif()

    if(NOT "${arg_VERSION}" MATCHES "${vcpkg_date_regex}")
        message(FATAL_ERROR
            "VERSION (${arg_VERSION}) 不是有效的日期 - 需要格式为 'YYYY-MM-DD' 的值"
        )
    endif()

    string(REPLACE "-" "." VCPKG_BASE_VERSION_as_dotted "${VCPKG_BASE_VERSION}")
    string(REPLACE "-" "." arg_VERSION_as_dotted "${arg_VERSION}")

    if("${VCPKG_BASE_VERSION_as_dotted}" VERSION_LESS "${arg_VERSION_as_dotted}")
        message(FATAL_ERROR
            "您的 vcpkg 可执行文件版本为 ${VCPKG_BASE_VERSION}，早于调用者通过 "
            "vcpkg_minimum_required(VERSION ${arg_VERSION}) 所要求的版本。"
            "请通过运行 bootstrap-vcpkg 重新获取 vcpkg。"
        )
    endif()
endfunction()
