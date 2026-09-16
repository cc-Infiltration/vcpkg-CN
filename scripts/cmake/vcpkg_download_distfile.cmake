function(z_vcpkg_download_distfile out_var)
    cmake_parse_arguments(PARSE_ARGV 1 arg
        "SKIP_SHA512;SILENT_EXIT;QUIET;ALWAYS_REDOWNLOAD"
        "FILENAME;SHA512"
        "URLS;HEADERS"
    )

    # SILENT_EXIT 和 QUIET 无实际意义，但接受并忽略它们可以让
    # vcpkg_download_distfile 直接透传参数而无需额外处理。
    if(NOT DEFINED arg_URLS)
        message(FATAL_ERROR "vcpkg_download_distfile 需要 URLS 参数。")
    endif()
    if(NOT DEFINED arg_FILENAME)
        message(FATAL_ERROR "vcpkg_download_distfile 需要 FILENAME 参数。")
    endif()
    # 注意 arg_ALWAYS_REDOWNLOAD 隐含 arg_SKIP_SHA512，而非 arg_SKIP_SHA512 隐含非 arg_ALWAYS_REDOWNLOAD
    if(arg_ALWAYS_REDOWNLOAD AND NOT arg_SKIP_SHA512)
        message(FATAL_ERROR "ALWAYS_REDOWNLOAD 需要 SKIP_SHA512")
    endif()

    if(NOT arg_SKIP_SHA512 AND NOT DEFINED arg_SHA512)
        message(FATAL_ERROR "vcpkg_download_distfile 需要 SHA512 参数。
如果你不知道 SHA512 值，请将其设为 'SHA512 0' 后重试。")
    elseif(arg_SKIP_SHA512 AND DEFINED arg_SHA512)
        message(FATAL_ERROR "SHA512 不能与 SKIP_SHA512 同时使用。")
    endif()

    if(_VCPKG_INTERNAL_NO_HASH_CHECK)
        set(arg_SKIP_SHA512 1)
    endif()

    if(NOT arg_SKIP_SHA512)
        if("${arg_SHA512}" STREQUAL "0")
            string(REPEAT 0 128 arg_SHA512)
        else()
            string(LENGTH "${arg_SHA512}" arg_SHA512_length)
            if(NOT "${arg_SHA512_length}" EQUAL "128" OR NOT "${arg_SHA512}" MATCHES "^[a-zA-Z0-9]*$")
                message(FATAL_ERROR "无效的 SHA512: ${arg_SHA512}。
    如果你不知道文件的 SHA512 值，请将其设为 \"0\"。")
            endif()

            string(TOLOWER "${arg_SHA512}" arg_SHA512)
        endif()
    endif()

    set(downloaded_file_path "${DOWNLOADS}/${arg_FILENAME}")

    get_filename_component(directory_component "${arg_FILENAME}" DIRECTORY)
    if ("${directory_component}" STREQUAL "")
        file(MAKE_DIRECTORY "${DOWNLOADS}")
    else()
        file(MAKE_DIRECTORY "${DOWNLOADS}/${directory_component}")
    endif()

    if(EXISTS "${downloaded_file_path}")
        if(arg_SKIP_SHA512)
            if(NOT arg_ALWAYS_REDOWNLOAD)
                if(NOT _VCPKG_INTERNAL_NO_HASH_CHECK)
                    message(STATUS "跳过哈希校验，使用缓存的 ${arg_FILENAME}")
                endif()

                set("${out_var}" "${downloaded_file_path}" PARENT_SCOPE)
                return()
            endif()
        else()
            # 注意 非 arg_SKIP_SHA512 隐含非 arg_ALWAYS_REDOWNLOAD
            file(SHA512 "${downloaded_file_path}" file_hash)
            if("${file_hash}" STREQUAL "${arg_SHA512}")
                message(STATUS "使用缓存的 ${arg_FILENAME}")
                set("${out_var}" "${downloaded_file_path}" PARENT_SCOPE)
                return()
            endif()

            # 已有文件的哈希不匹配。可能是期望的 SHA512 发生了变化。尝试将期望的 SHA512
            # 加入文件名后重新尝试，以尽量避免冲突。
            get_filename_component(filename_component "${arg_FILENAME}" NAME_WE)
            get_filename_component(extension_component "${arg_FILENAME}" EXT)
            string(SUBSTRING "${arg_SHA512}" 0 8 hash)
            set(arg_FILENAME "${filename_component}-${hash}${extension_component}")
            if (NOT "${directory_component}" STREQUAL "")
                set(arg_FILENAME "${directory_component}/${arg_FILENAME}")
            endif()

            set(downloaded_file_path "${DOWNLOADS}/${arg_FILENAME}")
            if(EXISTS "${downloaded_file_path}")
                if(_VCPKG_NO_DOWNLOADS)
                    set(advice_message "提示: 下载已禁用。请确保期望的文件已放置在 ${downloaded_file_path} 后重试")
                else()
                    set(advice_message "提示: 你可以通过重新下载文件来解决此问题。请删除 ${downloaded_file_path} 后重试")
                endif()

                file(SHA512 "${downloaded_file_path}" file_hash)
                if("${file_hash}" STREQUAL "${arg_SHA512}")
                    message(STATUS "使用缓存的 ${arg_FILENAME}")
                    set("${out_var}" "${downloaded_file_path}" PARENT_SCOPE)
                    return()
                endif()

                # 注意：额外的前导空格是为了防止 CMake 错误地尝试换行
                message(FATAL_ERROR
                    "  ${downloaded_file_path}: 错误: 已下载的文件哈希值不符合预期\n"
                    "  期望值: ${arg_SHA512}\n"
                    "  实际值: ${file_hash}\n"
                    "  ${advice_message}")
            endif()
        endif()
    endif()

    # vcpkg_download_distfile_ALWAYS_REDOWNLOAD 仅在非 _VCPKG_NO_DOWNLOADS 时触发
    # 这里可以用德摩根律简化，但当前写法更清晰
    if(_VCPKG_NO_DOWNLOADS)
        message(FATAL_ERROR "下载已禁用，但 '${downloaded_file_path}' 不存在")
    endif()

    vcpkg_list(SET params "x-download" "${arg_FILENAME}")
    # GitHub 链接优先使用镜像加速，原始链接作为兜底
    set(_vcpkg_mirror_urls "")
    set(_vcpkg_fallback_urls "")
    foreach(url IN LISTS arg_URLS)
        if(url MATCHES "^https://github\.com/" AND NOT url MATCHES "^https://down\.npee\.cn")
            vcpkg_list(APPEND _vcpkg_mirror_urls "--url=https://down.npee.cn?${url}")
            vcpkg_list(APPEND _vcpkg_fallback_urls "--url=${url}")
        else()
            vcpkg_list(APPEND _vcpkg_mirror_urls "--url=${url}")
        endif()
    endforeach()
    # 先尝试镜像，再回退到原始 GitHub 地址
    vcpkg_list(APPEND params ${_vcpkg_mirror_urls} ${_vcpkg_fallback_urls})

    foreach(header IN LISTS arg_HEADERS)
        list(APPEND params "--header=${header}")
    endforeach()

    if(arg_SKIP_SHA512)
        vcpkg_list(APPEND params "--skip-sha512")
    else()
        vcpkg_list(APPEND params "--sha512=${arg_SHA512}")
    endif()

    # 设置 WORKING_DIRECTORY 并传入相对路径 FILENAME，使得 vcpkg x-download 能打印
    # 包含 / 的完整相对路径。
    vcpkg_execute_in_download_mode(COMMAND "$ENV{VCPKG_COMMAND}" ${params} RESULT_VARIABLE error_code WORKING_DIRECTORY "${DOWNLOADS}")
    if(NOT "${error_code}" EQUAL "0")
        message(FATAL_ERROR "下载失败，终止 portfile 执行")
    endif()

    set("${out_var}" "${downloaded_file_path}" PARENT_SCOPE)
endfunction()

function(vcpkg_download_distfile out_var)
    cmake_parse_arguments(PARSE_ARGV 1 arg
        "SKIP_SHA512;SILENT_EXIT;QUIET;ALWAYS_REDOWNLOAD"
        "FILENAME;SHA512"
        "URLS;HEADERS"
    )
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        # 需要保留向后兼容性，参见
        # https://github.com/microsoft/vcpkg/blob/68b3d3404d0bc6f2a2287f64ed5f6aa777e70d56/ports/liblas/portfile.cmake#L9
        message("${Z_VCPKG_BACKCOMPAT_MESSAGE_LEVEL}" "vcpkg_download_distfile 收到了多余参数: ${arg_UNPARSED_ARGUMENTS}")
    endif()
    if(arg_SILENT_EXIT)
        message(WARNING "SILENT_EXIT 已无任何效果。要消除此警告，请移除 SILENT_EXIT")
    endif()

    z_vcpkg_function_arguments(forwarded_args 1)
    z_vcpkg_download_distfile("${out_var}" ${forwarded_args})
    set("${out_var}" "${${out_var}}" PARENT_SCOPE)

    list(GET arg_URLS 0 spdx_download_location)
    z_vcpkg_add_spdx_resource(
        NAME "${arg_FILENAME}"
        FILENAME "${arg_FILENAME}"
        DOWNLOAD_LOCATION "${spdx_download_location}"
        SHA512 "${arg_SHA512}"
    )
endfunction()
