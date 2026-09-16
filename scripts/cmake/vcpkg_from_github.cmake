function(vcpkg_from_github)
    cmake_parse_arguments(PARSE_ARGV 0 "arg"
        "USE_TARBALL_API"
        "OUT_SOURCE_PATH;REPO;REF;SHA512;HEAD_REF;GITHUB_HOST;AUTHORIZATION_TOKEN;FILE_DISAMBIGUATOR"
        "PATCHES")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "vcpkg_from_github 被传递了多余的参数: ${arg_UNPARSED_ARGUMENTS}")
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

    if(NOT DEFINED arg_GITHUB_HOST)
        set(github_host "https://github.com")
        set(github_api_url "https://api.github.com")
    else()
        set(github_host "${arg_GITHUB_HOST}")
        set(github_api_url "${arg_GITHUB_HOST}/api/v3")
    endif()

    set(headers_param "")
    if(DEFINED arg_AUTHORIZATION_TOKEN)
        set(headers_param "HEADERS" "Authorization: token ${arg_AUTHORIZATION_TOKEN}")
    endif()


    if(NOT DEFINED arg_REF AND NOT DEFINED arg_HEAD_REF)
        message(FATAL_ERROR "必须指定 REF 或 HEAD_REF 中的至少一个。")
    endif()

    if(NOT arg_REPO MATCHES "^([^/]*)/([^/]*)$")
        message(FATAL_ERROR "REPO (${arg_REPO}) 不是有效的仓库名称:
    必须是组织名后跟仓库名，以单个斜杠分隔。")
    endif()
    set(org_name "${CMAKE_MATCH_1}")
    set(repo_name "${CMAKE_MATCH_2}")

    if(VCPKG_USE_HEAD_VERSION AND NOT DEFINED arg_HEAD_REF)
        message(STATUS "包未指定 HEAD_REF。回退到非 HEAD 版本。")
        set(VCPKG_USE_HEAD_VERSION OFF)
    elseif(NOT VCPKG_USE_HEAD_VERSION AND NOT DEFINED arg_REF)
        message(FATAL_ERROR "包未指定 REF。必须使用 --head 进行构建。")
    endif()

    # 向调用者导出 VCPKG_HEAD_VERSION。这将在构建后被 ports.cmake 获取。
    if(VCPKG_USE_HEAD_VERSION)
        string(REPLACE "/" "_-" sanitized_head_ref "${arg_HEAD_REF}")
        z_vcpkg_download_distfile(archive_version
            URLS "${github_api_url}/repos/${org_name}/${repo_name}/git/refs/heads/${arg_HEAD_REF}"
            FILENAME "${org_name}-${repo_name}-${sanitized_head_ref}.version"
            ${headers_param}
            SKIP_SHA512
            ALWAYS_REDOWNLOAD
        )
        # 使用正则表达式解析 github refs 响应。
        file(READ "${archive_version}" version_contents)
        string(JSON head_version
            ERROR_VARIABLE head_version_err
            GET "${version_contents}"
            "object"
            "sha"
        )
        if(NOT "${head_version_err}" STREQUAL "NOTFOUND")
            message(FATAL_ERROR "无法解析来自 '${version_url}' 的 API 响应:
${version_contents}

错误为: ${head_version_err}
")
        endif()

        set(VCPKG_HEAD_VERSION "${head_version}" PARENT_SCOPE)
        set(ref_to_use "${head_version}")

        vcpkg_list(SET redownload_param ALWAYS_REDOWNLOAD)
        vcpkg_list(SET sha512_param SKIP_SHA512)
        vcpkg_list(SET working_directory_param WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/src/head")
        vcpkg_list(SET skip_patch_check_param SKIP_PATCH_CHECK)
    else()
        set(ref_to_use "${arg_REF}")

        vcpkg_list(SET redownload_param)
        vcpkg_list(SET working_directory_param)
        vcpkg_list(SET skip_patch_check_param)
        vcpkg_list(SET sha512_param SHA512 "${arg_SHA512}")
    endif()

    string(REPLACE "/" "_-" sanitized_ref "${ref_to_use}")
    if(DEFINED arg_FILE_DISAMBIGUATOR AND NOT VCPKG_USE_HEAD_REF)
        set(downloaded_file_name "${org_name}-${repo_name}-${sanitized_ref}-${arg_FILE_DISAMBIGUATOR}.tar.gz")
    else()
        set(downloaded_file_name "${org_name}-${repo_name}-${sanitized_ref}.tar.gz")
    endif()

    if(arg_USE_TARBALL_API)
        # 此备用端点对 GitHub 的个人访问令牌有更好的支持
        # （例如当组织内启用了 SSO 时）。
        set(download_url
            "${github_api_url}/repos/${org_name}/${repo_name}/tarball/${ref_to_use}"
        )
    else()
        set(download_url
            "${github_host}/${org_name}/${repo_name}/archive/${ref_to_use}.tar.gz"
        )
    endif()

    # 尝试从 github 下载文件信息
    z_vcpkg_download_distfile(archive
        URLS "${download_url}"
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
        ${skip_patch_check_param}
    )
    z_vcpkg_add_spdx_resource(
        NAME "${arg_REPO}"
        DOWNLOAD_LOCATION "git+${github_host}/${arg_REPO}@${ref_to_use}"
        SHA512 "${arg_SHA512}"
    )
    set("${arg_OUT_SOURCE_PATH}" "${SOURCE_PATH}" PARENT_SCOPE)
endfunction()
