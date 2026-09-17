function(vcpkg_install_copyright)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "COMMENT" "FILE_LIST")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} 被传递了多余的参数: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    if(NOT DEFINED arg_FILE_LIST)
        message(FATAL_ERROR "必须指定 FILE_LIST")
    endif()

    list(LENGTH arg_FILE_LIST FILE_LIST_LENGTH)
    set(out_string "")
    
    if(FILE_LIST_LENGTH LESS_EQUAL 0)
        message(FATAL_ERROR "FILE_LIST 必须至少包含一个文件")
    elseif(FILE_LIST_LENGTH EQUAL 1)
        if(arg_COMMENT)
            file(READ "${arg_FILE_LIST}" out_string)
        else()
            file(INSTALL "${arg_FILE_LIST}" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
            return()
        endif()
    else()
        foreach(file_item IN LISTS arg_FILE_LIST)
            if(NOT EXISTS "${file_item}")
                message(FATAL_ERROR "\n${CMAKE_CURRENT_FUNCTION} 被传递了不存在的路径: ${file_item}\n")
            endif()

            get_filename_component(file_name "${file_item}" NAME)
            file(READ "${file_item}" file_contents)

            string(APPEND out_string "${file_name}:\n\n${file_contents}\n\n")
        endforeach()
    endif()

    if(arg_COMMENT)
        string(PREPEND out_string "${arg_COMMENT}\n\n")
    endif()

    file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "${out_string}")
endfunction()
