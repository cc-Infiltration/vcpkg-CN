# 注意：此函数定义已直接复制到 scripts/buildsystems/vcpkg.cmake
# 不要仅在此处修改而不同步修改另一处。
macro(z_vcpkg_function_arguments OUT_VAR)
    if("${ARGC}" EQUAL 1)
        set(z_vcpkg_function_arguments_FIRST_ARG 0)
    elseif("${ARGC}" EQUAL 2)
        set(z_vcpkg_function_arguments_FIRST_ARG "${ARGV1}")

        if(NOT z_vcpkg_function_arguments_FIRST_ARG GREATER_EQUAL "0" AND NOT z_vcpkg_function_arguments_FIRST_ARG LESS "0")
            message(FATAL_ERROR "z_vcpkg_function_arguments：索引 (${z_vcpkg_function_arguments_FIRST_ARG}) 不是数字")
        elseif(z_vcpkg_function_arguments_FIRST_ARG LESS "0" OR z_vcpkg_function_arguments_FIRST_ARG GREATER ARGC)
            message(FATAL_ERROR "z_vcpkg_function_arguments：索引 (${z_vcpkg_function_arguments_FIRST_ARG}) 超出范围")
        endif()
    else()
        # vcpkg 内部错误
        message(FATAL_ERROR "z_vcpkg_function_arguments：无效的参数 (${ARGV})")
    endif()

    set("${OUT_VAR}" "")

    # 这使我们能够获取外层函数的 ARGC 值
    set(z_vcpkg_function_arguments_ARGC_NAME "ARGC")
    set(z_vcpkg_function_arguments_ARGC "${${z_vcpkg_function_arguments_ARGC_NAME}}")

    math(EXPR z_vcpkg_function_arguments_LAST_ARG "${z_vcpkg_function_arguments_ARGC} - 1")
    # GREATER_EQUAL 在 CMake 3.7 中引入
    if(NOT z_vcpkg_function_arguments_LAST_ARG LESS z_vcpkg_function_arguments_FIRST_ARG)
        foreach(z_vcpkg_function_arguments_N RANGE "${z_vcpkg_function_arguments_FIRST_ARG}" "${z_vcpkg_function_arguments_LAST_ARG}")
            string(REPLACE ";" "\\;" z_vcpkg_function_arguments_ESCAPED_ARG "${ARGV${z_vcpkg_function_arguments_N}}")
            # 在开头添加一个额外的 ";"
            set("${OUT_VAR}" "${${OUT_VAR}};${z_vcpkg_function_arguments_ESCAPED_ARG}")
        endforeach()
        # 然后移除那个额外的分号
        string(SUBSTRING "${${OUT_VAR}}" 1 -1 "${OUT_VAR}")
    endif()
endmacro()
