function(vcpkg_extract_archive)
    cmake_parse_arguments(PARSE_ARGV 0 "arg"
        ""
        "ARCHIVE;DESTINATION"
        ""
    )

    foreach(arg_name IN ITEMS ARCHIVE DESTINATION)
        if(NOT DEFINED "arg_${arg_name}")
            message(FATAL_ERROR "${arg_name} 是必需的。")
        endif()
    endforeach()

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "无法识别的参数: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    if(EXISTS "${arg_DESTINATION}")
        message(FATAL_ERROR "${arg_DESTINATION} 是解压目标，但它已经存在。")
    endif()

    file(MAKE_DIRECTORY "${arg_DESTINATION}")

    cmake_path(GET arg_ARCHIVE EXTENSION archive_extension)
    string(TOLOWER "${archive_extension}" archive_extension)
    if("${archive_extension}" MATCHES [[\.msi$]])
        cmake_path(NATIVE_PATH arg_ARCHIVE archive_native_path)
        cmake_path(NATIVE_PATH arg_DESTINATION destination_native_path)
        cmake_path(GET arg_ARCHIVE PARENT_PATH archive_directory)
        vcpkg_execute_in_download_mode(
            COMMAND msiexec
                /a "${archive_native_path}"
                /qn "TARGETDIR=${destination_native_path}"
            WORKING_DIRECTORY "${archive_directory}"
        )
    elseif("${archive_extension}" MATCHES [[\.exe$]])
        vcpkg_execute_in_download_mode(
            COMMAND "$ENV{VCPKG_COMMAND}" z-extract "${arg_ARCHIVE}" "${arg_DESTINATION}")
    else()
        vcpkg_execute_in_download_mode(
            COMMAND "${CMAKE_COMMAND}" -E tar xzf "${arg_ARCHIVE}"
            WORKING_DIRECTORY "${arg_DESTINATION}"
        )
    endif()
endfunction()
