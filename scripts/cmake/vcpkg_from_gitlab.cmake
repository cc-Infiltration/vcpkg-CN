function(z_uri_encode input output_variable)
    string(HEX "${input}" hex)
    string(LENGTH "${hex}" length)
    math(EXPR last "${length} - 1")
    set(result "")
    foreach(i RANGE ${last})
        math(EXPR even "${i} % 2")
        if("${even}" STREQUAL "0")
            string(SUBSTRING "${hex}" "${i}" 2 char)
            string(APPEND result "%${char}")
        endif()
    endforeach()
    set("${output_variable}" ${result} PARENT_SCOPE)
endfunction()

function(vcpkg_from_gitlab)
    cmake_parse_arguments(PARSE_ARGV 0 "arg"
        ""
        "OUT_SOURCE_PATH;GITLAB_URL;REPO;REF;SHA512;HEAD_REF;FILE_DISAMBIGUATOR;AUTHORIZATION_TOKEN"
        "PATCHES")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "vcpkg_from_gitlab 被传递了多余的参数: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    if(NOT DEFINED arg_GITLAB_URL)
        message(FATAL_ERROR "必须指定 GITLAB_URL。")
    endif()

    if(DEFINED arg_REF AND NOT DEFINED arg_SHA512)
        message(FATAL_ERROR "如果指定了 REF，则必须指定 SHA512。")
    endif()
    if(NOT DEFINED arg_REF AND DEFINED arg_SHA512)
        message(FATAL_ERROR "如果指定了 SHA512，则必须指定 REF。")
    endif()

    if(NOT DEFINED arg_OUT_SOURCE_PATH)
        message(FATAL_ERROR "必须指定 OUT_SOURCE_PATH。")
    endif()
    if(NOT DEFINED arg_REPO)
        message(FATAL_ERROR "必须指定 GitHub 仓库。")
    endif()

    set(headers_param "")
    if(DEFINED arg_AUTHORIZATION_TOKEN)
        set(headers_param "HEADERS" "PRIVATE-TOKEN: ${arg_AUTHORIZATION_TOKEN}")
    endif()

    if(NOT DEFINED arg_REF AND NOT DEFINED arg_HEAD_REF)
        message(FATAL_ERROR "必须指定 REF 或 HEAD_REF 中的至少一个。")
    endif()

    if (NOT arg_REPO MATCHES [[^([^/;]+/)+([^/;]+)$]])
        message(FATAL_ERROR "REPO (${arg_REPO}) 不是有效的仓库名称。必须是:
    - 组织名后跟仓库名，以单个斜杠分隔，或
    - 组织名、组名、子组名和仓库名，以斜杠分隔。")
    endif()
    set(gitlab_link "${arg_GITLAB_URL}/${arg_REPO}")
    string(REPLACE "/" "-" downloaded_file_name_base "${arg_REPO}")
    string(REPLACE "/" ";" repo_parts "${arg_REPO}")
    list(GET repo_parts -1 repo_name)

    set(redownload_param "")
    set(working_directory_param "")
    set(sha512_param "SHA512" "${arg_SHA512}")
    set(ref_to_use "${arg_REF}")
    if(VCPKG_USE_HEAD_VERSION)
        if(DEFINED arg_HEAD_REF)
            set(redownload_param "ALWAYS_REDOWNLOAD")
            set(sha512_param "SKIP_SHA512")
            set(working_directory_param "WORKING_DIRECTORY" "${CURRENT_BUILDTREES_DIR}/src/head")
            set(ref_to_use "${arg_HEAD_REF}")
        else()
            message(STATUS "包未指定 HEAD_REF。回退到非 HEAD 版本。")
        endif()
    elseif(NOT DEFINED arg_REF)
        message(FATAL_ERROR "包未指定 REF。必须使用 --head 进行构建。")
    endif()

    # 避免使用 - 或 _，以允许 `foo/bar` 和 `foo-bar` 共存
    # 我们假设没有人会将 ref 命名为 "foo_-bar"
    string(REPLACE "/" "_-" sanitized_ref "${ref_to_use}")
    if(DEFINED arg_FILE_DISAMBIGUATOR AND NOT VCPKG_USE_HEAD_VERSION)
        set(downloaded_file_name "${downloaded_file_name_base}-${sanitized_ref}-${arg_FILE_DISAMBIGUATOR}.tar.gz")
    else()
        set(downloaded_file_name "${downloaded_file_name_base}-${sanitized_ref}.tar.gz")
    endif()


    # 向调用者导出 VCPKG_HEAD_VERSION。这将在构建后被 ports.cmake 获取。
    # 当多个 vcpkg_from_gitlab 连续使用时，只使用第一个（希望是主要的那个）的版本。
    if(VCPKG_USE_HEAD_VERSION AND NOT DEFINED VCPKG_HEAD_VERSION)
        z_uri_encode("${arg_REPO}" encoded_repo_path)
        set(version_url "${arg_GITLAB_URL}/api/v4/projects/${encoded_repo_path}/repository/branches/${arg_HEAD_REF}")
        z_vcpkg_download_distfile(archive_version
            URLS "${version_url}"
            FILENAME "${downloaded_file_name}.version"
            ${headers_param}
            SKIP_SHA512
            ALWAYS_REDOWNLOAD
        )
        # 使用正则表达式解析 gitlab 响应。
        file(READ "${archive_version}" version_contents)
        if(NOT version_contents MATCHES [["id":(\ *)"([a-f0-9]+)"]])
            message(FATAL_ERROR "无法解析来自 '${version_url}' 的 API 响应:\n${version_contents}\n")
        endif()
        set(VCPKG_HEAD_VERSION "${CMAKE_MATCH_2}" PARENT_SCOPE)
    endif()

    # 从 gitlab 下载文件信息
    z_vcpkg_download_distfile(archive
        URLS "${gitlab_link}/-/archive/${ref_to_use}/${repo_name}-${ref_to_use}.tar.gz"
        FILENAME "${downloaded_file_name}"
        ${headers_param}
        ${sha512_param}
        ${redownload_param}
    )
    vcpkg_extract_source_archive_ex(
        OUT_SOURCE_PATH SOURCE_PATH
        ARCHIVE "${archive}"
        REF "${sanitized_ref}"
        PATCHES ${arg_PATCHES}
        ${working_directory_param}
    )
    z_vcpkg_add_spdx_resource(
        NAME "${arg_REPO}"
        DOWNLOAD_LOCATION "git+${arg_GITLAB_URL}/${arg_REPO}@${ref_to_use}"
        SHA512 "${arg_SHA512}"
    )
    set("${arg_OUT_SOURCE_PATH}" "${SOURCE_PATH}" PARENT_SCOPE)
endfunction()
