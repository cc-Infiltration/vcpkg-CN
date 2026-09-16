function(vcpkg_from_git)
    cmake_parse_arguments(PARSE_ARGV 0 "arg"
        ""
        "OUT_SOURCE_PATH;URL;REF;FETCH_REF;HEAD_REF;TAG;LFS"
        "PATCHES"
    )

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "vcpkg_from_git 被传递了多余的参数: ${arg_UNPARSED_ARGUMENTS}")
    endif()
    if(DEFINED arg_TAG)
        message(WARNING "vcpkg_from_git 的 TAG 参数已被弃用且无效。")
    endif()

    if(NOT DEFINED arg_OUT_SOURCE_PATH)
        message(FATAL_ERROR "必须指定 OUT_SOURCE_PATH")
    endif()
    if(NOT DEFINED arg_URL)
        message(FATAL_ERROR "必须指定 URL")
    endif()
    if(NOT DEFINED arg_REF AND NOT DEFINED arg_HEAD_REF)
        message(FATAL_ERROR "必须指定 REF 或 HEAD_REF 中的至少一个")
    endif()
    if(DEFINED arg_FETCH_REF AND NOT DEFINED arg_REF)
        message(FATAL_ERROR "如果指定了 FETCH_REF，则必须指定 REF")
    endif()
    if(DEFINED arg_LFS AND arg_LFS STREQUAL "")
        set(arg_LFS "${arg_URL}")
    endif()

    vcpkg_list(SET git_fetch_shallow_param --depth 1)
    vcpkg_list(SET extract_working_directory_param)
    vcpkg_list(SET skip_patch_check_param)
    set(git_working_directory "${DOWNLOADS}/git-tmp")
    set(do_download OFF)

    if(VCPKG_USE_HEAD_VERSION AND DEFINED arg_HEAD_REF)
        vcpkg_list(SET working_directory_param "WORKING_DIRECTORY" "${CURRENT_BUILDTREES_DIR}/src/head")
        vcpkg_list(SET git_fetch_shallow_param --depth 1)
        vcpkg_list(SET skip_patch_check_param SKIP_PATCH_CHECK)
        set(ref_to_fetch "${arg_HEAD_REF}")
        set(git_working_directory "${CURRENT_BUILDTREES_DIR}/src/git-tmp")
        string(REPLACE "/" "_-" sanitized_ref "${arg_HEAD_REF}")

        if(NOT _VCPKG_NO_DOWNLOADS)
            set(do_download ON)
        endif()
    else()
        if(NOT DEFINED arg_REF)
            message(FATAL_ERROR "包未指定 REF。必须使用 --head 进行构建。")
        endif()
        if(VCPKG_USE_HEAD_VERSION)
            message(STATUS "包未指定 HEAD_REF。回退到非 HEAD 版本。")
        endif()

        if(DEFINED arg_FETCH_REF)
            set(ref_to_fetch "${arg_FETCH_REF}")
            vcpkg_list(SET git_fetch_shallow_param)
        else()
            set(ref_to_fetch "${arg_REF}")
        endif()
        string(REPLACE "/" "_-" sanitized_ref "${arg_REF}")
    endif()

    set(temp_archive "${DOWNLOADS}/temp/${PORT}-${sanitized_ref}.tar.gz")
    set(archive "${DOWNLOADS}/${PORT}-${sanitized_ref}.tar.gz")

    if(NOT EXISTS "${archive}")
        if(_VCPKG_NO_DOWNLOADS)
            message(FATAL_ERROR "下载已禁用，但 '${archive}' 不存在。")
        endif()
        set(do_download ON)
    endif()

    if(do_download)
        message(STATUS "正在获取 ${arg_URL} ${ref_to_fetch}...")
        find_program(GIT NAMES git git.cmd)
        file(MAKE_DIRECTORY "${DOWNLOADS}")
        # 注意: git init 可以安全地多次运行
        vcpkg_execute_required_process(
            ALLOW_IN_DOWNLOAD_MODE
            COMMAND "${GIT}" init "${git_working_directory}"
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
            LOGNAME "git-init-${TARGET_TRIPLET}"
        )
        vcpkg_execute_required_process(
            ALLOW_IN_DOWNLOAD_MODE
            COMMAND "${GIT}" fetch "${arg_URL}" "${ref_to_fetch}" ${git_fetch_shallow_param} -n
            WORKING_DIRECTORY "${git_working_directory}"
            LOGNAME "git-fetch-${TARGET_TRIPLET}"
        )
        if(arg_LFS)
            # 运行 "git lfs" 会在路径中搜索 "git-lfs[.exe]"
            vcpkg_execute_in_download_mode(
                COMMAND "${GIT}" lfs --version
                OUTPUT_VARIABLE lfs_version_output
                ERROR_VARIABLE lfs_version_error
                RESULT_VARIABLE lfs_version_result
                WORKING_DIRECTORY "${git_working_directory}"
            )
            if(lfs_version_result)
                message(FATAL_ERROR "${PORT} 需要 Git LFS")
            endif()

            vcpkg_execute_required_process(
                ALLOW_IN_DOWNLOAD_MODE
                COMMAND "${GIT}" lfs install --local --force --skip-repo
                WORKING_DIRECTORY "${git_working_directory}"
                LOGNAME "git-lfs-install-${TARGET_TRIPLET}"
            )
            vcpkg_execute_required_process(
                ALLOW_IN_DOWNLOAD_MODE
                COMMAND "${GIT}" lfs fetch "${arg_LFS}" "${ref_to_fetch}"
                WORKING_DIRECTORY "${git_working_directory}"
                LOGNAME "git-lfs-fetch-${TARGET_TRIPLET}"
            )
        endif()

        if(VCPKG_USE_HEAD_VERSION)
            set(expected_rev_parse FETCH_HEAD)
        else()
            set(expected_rev_parse "${arg_REF}")
        endif()

        vcpkg_execute_in_download_mode(
            COMMAND "${GIT}" rev-parse "${expected_rev_parse}"
            OUTPUT_VARIABLE rev_parse_ref
            ERROR_VARIABLE rev_parse_ref
            RESULT_VARIABLE error_code
            WORKING_DIRECTORY "${git_working_directory}"
        )

        if(error_code)
            if(VCPKG_USE_HEAD_VERSION)
                message(FATAL_ERROR "无法确定要使用的 HEAD 版本的提交 SHA，在从 git 仓库获取 \
${ref_to_fetch} 之后。(git rev-parse ${expected_rev_parse} 失败)")
            elseif(DEFINED arg_FETCH_REF)
                message(FATAL_ERROR "获取 ${ref_to_fetch} 后，目标 ref ${expected_rev_parse} 似乎\
不可访问。此失败的常见原因是将 REF 设置为命名分支或标签而非提交 SHA。REF \
必须是提交 SHA。(git rev-parse ${expected_rev_parse} 失败)")
            else()
                message(FATAL_ERROR "获取 ${ref_to_fetch} 后，目标 ref ${expected_rev_parse} 似乎\
不可访问。此失败的常见原因是将 REF 设置为命名分支或标签而非提交 SHA。REF \
必须是提交 SHA。如果 git 服务器不公布提交 SHA \
(uploadpack.allowReachableSHA1InWant 为 false)，你可以将 FETCH_REF 设置为一个包含所需提交 \
SHA 历史记录的命名分支。例如，你可以通过将 \"REF ${arg_REF}\" 更改为 \
\"REF a-commit-sha FETCH_REF ${arg_REF}\" 来修复此错误。(git rev-parse ${expected_rev_parse} 失败)")
            endif()
        endif()

        string(STRIP "${rev_parse_ref}" rev_parse_ref)
        if(VCPKG_USE_HEAD_VERSION)
            set(VCPKG_HEAD_VERSION "${rev_parse_ref}" PARENT_SCOPE)
        elseif(NOT "${rev_parse_ref}" STREQUAL "${arg_REF}")
                message(FATAL_ERROR "获取 ${ref_to_fetch} 后，请求的 REF (${arg_REF}) 与 git rev-parse 返回的\
提交 SHA (${rev_parse_ref}) 不匹配。这通常是因为尝试将 REF 设置为命名\
分支或标签而非提交 SHA。REF 必须是提交 SHA。如果 git 服务器不公布提交 SHA \
(uploadpack.allowReachableSHA1InWant 为 false)，你可以将 FETCH_REF 设置为一个包含所需提交 \
SHA 历史记录的命名分支。例如，你可以通过将 \"REF ${arg_REF}\" 更改为 \
\"REF a-commit-sha FETCH_REF ${arg_REF}\" 来修复此错误。
    [期望值 : ( ${arg_REF} )])
    [  实际值 : ( ${rev_parse_ref} )]"
            )
        endif()

        file(MAKE_DIRECTORY "${DOWNLOADS}/temp")
        vcpkg_execute_required_process(
            ALLOW_IN_DOWNLOAD_MODE
            COMMAND "${GIT}" -c core.autocrlf=false archive "${rev_parse_ref}" -o "${temp_archive}"
            WORKING_DIRECTORY "${git_working_directory}"
            LOGNAME git-archive
        )
        file(RENAME "${temp_archive}" "${archive}")
    else()
        message(STATUS "使用缓存的 ${archive}")
    endif()

    vcpkg_extract_source_archive_ex(
        OUT_SOURCE_PATH SOURCE_PATH
        ARCHIVE "${archive}"
        REF "${sanitized_ref}"
        PATCHES ${arg_PATCHES}
        NO_REMOVE_ONE_LEVEL
        ${extract_working_directory_param}
        ${skip_patch_check_param}
    )

    if(VCPKG_USE_HEAD_VERSION AND DEFINED arg_HEAD_REF)
        set(spdx_ref "${rev_parse_ref}")
    else()
        set(spdx_ref "${arg_REF}")
    endif()
    z_vcpkg_add_spdx_resource(
        NAME "${arg_URL}"
        DOWNLOAD_LOCATION "git+${arg_URL}@${spdx_ref}"
    )
    set("${arg_OUT_SOURCE_PATH}" "${SOURCE_PATH}" PARENT_SCOPE)
endfunction()
