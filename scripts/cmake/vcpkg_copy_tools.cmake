function(vcpkg_copy_tools)
    cmake_parse_arguments(PARSE_ARGV 0 arg "AUTO_CLEAN" "SEARCH_DIR;DESTINATION" "TOOL_NAMES")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "${CMAKE_CURRENT_FUNCTION} 传入了多余的参数：${arg_UNPARSED_ARGUMENTS}")
    endif()

    if(NOT DEFINED arg_TOOL_NAMES)
        message(FATAL_ERROR "必须指定 TOOL_NAMES。")
    endif()

    if(NOT DEFINED arg_DESTINATION)
        set(arg_DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    endif()

    if(NOT DEFINED arg_SEARCH_DIR)
        set(arg_SEARCH_DIR "${CURRENT_PACKAGES_DIR}/bin")
    elseif(NOT IS_DIRECTORY "${arg_SEARCH_DIR}")
        message(FATAL_ERROR "SEARCH_DIR（${arg_SEARCH_DIR}）必须是一个目录")
    endif()

    foreach(tool_name IN LISTS arg_TOOL_NAMES)
        set(tool_path "${arg_SEARCH_DIR}/${tool_name}${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
        set(tool_pdb "${arg_SEARCH_DIR}/${tool_name}.pdb")
        if(EXISTS "${tool_path}")
            file(COPY "${tool_path}" DESTINATION "${arg_DESTINATION}")
        elseif(NOT "${VCPKG_TARGET_BUNDLE_SUFFIX}" STREQUAL "" AND NOT "${VCPKG_TARGET_BUNDLE_SUFFIX}" STREQUAL "${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
            set(bundle_path "${arg_SEARCH_DIR}/${tool_name}${VCPKG_TARGET_BUNDLE_SUFFIX}")
            if(EXISTS "${bundle_path}")
                file(COPY "${bundle_path}" DESTINATION "${arg_DESTINATION}")
            else()
                message(FATAL_ERROR "找不到工具 \"${tool_name}\"：
    \"${tool_path}\" 和 \"${bundle_path}\" 均不存在")
            endif()
        else()
            message(FATAL_ERROR "找不到工具 \"${tool_name}\"：
    \"${tool_path}\" 不存在")
        endif()
        if(EXISTS "${tool_pdb}")
            file(COPY "${tool_pdb}" DESTINATION "${arg_DESTINATION}")
        endif()
    endforeach()

    if(arg_AUTO_CLEAN)
        vcpkg_clean_executables_in_bin(FILE_NAMES ${arg_TOOL_NAMES})
    endif()

    vcpkg_copy_tool_dependencies("${arg_DESTINATION}")
endfunction()
