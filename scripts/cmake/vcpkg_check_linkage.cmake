function(vcpkg_check_linkage)
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "ONLY_STATIC_LIBRARY;ONLY_DYNAMIC_LIBRARY;ONLY_DYNAMIC_CRT;ONLY_STATIC_CRT"
        ""
        ""
    )

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "${CMAKE_CURRENT_FUNCTION} 传入了多余的参数：${arg_UNPARSED_ARGUMENTS}")
    endif()

    if(arg_ONLY_STATIC_LIBRARY AND arg_ONLY_DYNAMIC_LIBRARY)
        message(FATAL_ERROR "同时请求 ONLY_STATIC_LIBRARY 和 ONLY_DYNAMIC_LIBRARY；这是一个错误。")
    endif()
    if(arg_ONLY_STATIC_CRT AND arg_ONLY_DYNAMIC_CRT)
        message(FATAL_ERROR "同时请求 ONLY_STATIC_CRT 和 ONLY_DYNAMIC_CRT；这是一个错误。")
    endif()

    if(arg_ONLY_STATIC_LIBRARY AND "${VCPKG_LIBRARY_LINKAGE}" STREQUAL "dynamic")
        message(STATUS "注意：${PORT} 仅支持静态库链接。正在构建静态库。")
        set(VCPKG_LIBRARY_LINKAGE static PARENT_SCOPE)
    elseif(arg_ONLY_DYNAMIC_LIBRARY AND "${VCPKG_LIBRARY_LINKAGE}" STREQUAL "static")
        if("${VCPKG_CRT_LINKAGE}" STREQUAL "static")
            message(FATAL_ERROR "此端口只能构建为动态库，但三元组（triplet）\
选择了静态库和静态 CRT。使用静态 CRT 构建动态库会产生\
许多开发者意想不到的情况，大多数端口对此并未做好准备。因此，\
vcpkg 报错而非将 VCPKG_LIBRARY_LINKAGE 改为动态。\

请考虑选择一个将 VCPKG_CRT_LINKAGE 设置为动态的三元组。如需了解更多信息，\
或想在自定义三元组中显式请求此配置，请参阅 \
https://learn.microsoft.com/vcpkg/maintainers/functions/vcpkg_check_linkage?WT.mc_id=vcpkg_inproduct_cli#notes \

如果你能编辑调用 vcpkg_check_linkage 并输出此消息的端口，请考虑在 \
\"supports\" 表达式中添加 !(static & staticcrt)，以便此组合能够提前失败。")
        else()
            message(STATUS "注意：${PORT} 仅支持动态库链接。正在构建动态库。")
        endif()

        set(VCPKG_LIBRARY_LINKAGE dynamic PARENT_SCOPE)
    endif()

    if(arg_ONLY_DYNAMIC_CRT AND "${VCPKG_CRT_LINKAGE}" STREQUAL "static")
        message(FATAL_ERROR "${PORT} 仅支持动态 CRT 链接")
    elseif(arg_ONLY_STATIC_CRT AND "${VCPKG_CRT_LINKAGE}" STREQUAL "dynamic")
        message(FATAL_ERROR "${PORT} 仅支持静态 CRT 链接")
    endif()
endfunction()
