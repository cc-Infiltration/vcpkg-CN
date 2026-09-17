function(vcpkg_extract_source_archive_ex)
    # OUT_SOURCE_PATH 是一个输出参数，因此我们需要解析它
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "" "OUT_SOURCE_PATH" "")
    if(NOT DEFINED arg_OUT_SOURCE_PATH)
        message(FATAL_ERROR "必须指定 OUT_SOURCE_PATH")
    endif()

    vcpkg_extract_source_archive(source_path ${arg_UNPARSED_ARGUMENTS} Z_ALLOW_OLD_PARAMETER_NAMES)

    set("${arg_OUT_SOURCE_PATH}" "${source_path}" PARENT_SCOPE)
endfunction()
