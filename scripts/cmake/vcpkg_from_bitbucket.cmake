function(vcpkg_from_bitbucket)
    cmake_parse_arguments(PARSE_ARGV 0 "arg"
        ""
        "OUT_SOURCE_PATH;REPO;REF;SHA512;HEAD_REF"
        "PATCHES")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "vcpkg_from_bitbucket 被传递了多余的参数: ${arg_UNPARSED_ARGUMENTS}")
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
        message(FATAL_ERROR "必须指定 Bitbucket 仓库。")
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
    set(downloaded_file_name "${org_name}-${repo_name}-${sanitized_ref}.tar.gz")

    # 向调用者导出 VCPKG_HEAD_VERSION。这将在构建后被 ports.cmake 获取。
    if(VCPKG_USE_HEAD_VERSION)
        z_vcpkg_download_distfile(archive_version
            URLS "https://api.bitbucket.com/2.0/repositories/${org_name}/${repo_name}/refs/branches/${arg_HEAD_REF}"
            FILENAME "${downloaded_file_name}.version"
            SKIP_SHA512
            ALWAYS_REDOWNLOAD
        )
        # 使用正则表达式解析 github refs 响应。
        # TODO: 为 vcpkg 添加 json-pointer 支持
        file(READ "${archive_version}" version_contents)
        if(NOT version_contents MATCHES [["hash": "([a-f0-9]+)"]])
            message(FATAL_ERROR "无法解析来自 '${version_url}' 的 API 响应:

${version_contents}
")
        endif()
        set(VCPKG_HEAD_VERSION "${CMAKE_MATCH_1}" PARENT_SCOPE)
    endif()

    # 从 bitbucket 下载文件信息。
    z_vcpkg_download_distfile(archive
        URLS "https://bitbucket.com/${org_name}/${repo_name}/get/${ref_to_use}.tar.gz"
        FILENAME "${downloaded_file_name}"
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
        DOWNLOAD_LOCATION "git+https://bitbucket.com/${arg_REPO}@${ref_to_use}"
        SHA512 "${arg_SHA512}"
    )
    set("${arg_OUT_SOURCE_PATH}" "${SOURCE_PATH}" PARENT_SCOPE)
endfunction()
