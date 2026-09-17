function(vcpkg_fixup_cmake_targets)
    if(Z_VCPKG_CMAKE_CONFIG_FIXUP_GUARD)
        message(FATAL_ERROR "${PORT} 端口已经依赖 vcpkg-cmake-config；在同一端口中同时使用 vcpkg-cmake-config 和 vcpkg_fixup_cmake_targets 是不受支持的。")
    endif()

    cmake_parse_arguments(PARSE_ARGV 0 arg "DO_NOT_DELETE_PARENT_CONFIG_PATH;NO_PREFIX_CORRECTION" "CONFIG_PATH;TARGET_PATH;TOOLS_PATH" "")

    if(arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "vcpkg_fixup_cmake_targets 被传递了多余的参数: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    if(NOT arg_TARGET_PATH)
        set(arg_TARGET_PATH share/${PORT})
    endif()
    
    if(NOT arg_TOOLS_PATH)
        set(arg_TOOLS_PATH tools/${PORT})
    endif()

    string(REPLACE "." "\\." EXECUTABLE_SUFFIX "${VCPKG_TARGET_EXECUTABLE_SUFFIX}")

    set(DEBUG_SHARE ${CURRENT_PACKAGES_DIR}/debug/${arg_TARGET_PATH})
    set(RELEASE_SHARE ${CURRENT_PACKAGES_DIR}/${arg_TARGET_PATH})

    if(arg_CONFIG_PATH AND NOT RELEASE_SHARE STREQUAL "${CURRENT_PACKAGES_DIR}/${arg_CONFIG_PATH}")
        if(arg_CONFIG_PATH STREQUAL "share")
            file(RENAME ${CURRENT_PACKAGES_DIR}/debug/share ${CURRENT_PACKAGES_DIR}/debug/share2)
            file(RENAME ${CURRENT_PACKAGES_DIR}/share ${CURRENT_PACKAGES_DIR}/share2)
            set(arg_CONFIG_PATH share2)
        endif()

        set(DEBUG_CONFIG ${CURRENT_PACKAGES_DIR}/debug/${arg_CONFIG_PATH})
        set(RELEASE_CONFIG ${CURRENT_PACKAGES_DIR}/${arg_CONFIG_PATH})
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
            if(NOT EXISTS ${DEBUG_CONFIG})
                message(FATAL_ERROR "'${DEBUG_CONFIG}' 不存在。")
            endif()

            # 这种迂回处理方式使得 CONFIG_PATH share 成为可能
            file(MAKE_DIRECTORY ${DEBUG_SHARE})
            file(GLOB FILES ${DEBUG_CONFIG}/*)
            file(COPY ${FILES} DESTINATION ${DEBUG_SHARE})
            file(REMOVE_RECURSE ${DEBUG_CONFIG})
        endif()

        file(GLOB FILES ${RELEASE_CONFIG}/*)
        file(COPY ${FILES} DESTINATION ${RELEASE_SHARE})
        file(REMOVE_RECURSE ${RELEASE_CONFIG})

        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
            get_filename_component(DEBUG_CONFIG_DIR_NAME ${DEBUG_CONFIG} NAME)
            string(TOLOWER "${DEBUG_CONFIG_DIR_NAME}" DEBUG_CONFIG_DIR_NAME)
            if(DEBUG_CONFIG_DIR_NAME STREQUAL "cmake" AND NOT arg_DO_NOT_DELETE_PARENT_CONFIG_PATH)
                file(REMOVE_RECURSE ${DEBUG_CONFIG})
            else()
                get_filename_component(DEBUG_CONFIG_PARENT_DIR ${DEBUG_CONFIG} DIRECTORY)
                get_filename_component(DEBUG_CONFIG_DIR_NAME ${DEBUG_CONFIG_PARENT_DIR} NAME)
                string(TOLOWER "${DEBUG_CONFIG_DIR_NAME}" DEBUG_CONFIG_DIR_NAME)
                if(DEBUG_CONFIG_DIR_NAME STREQUAL "cmake" AND NOT arg_DO_NOT_DELETE_PARENT_CONFIG_PATH)
                    file(REMOVE_RECURSE ${DEBUG_CONFIG_PARENT_DIR})
                endif()
            endif()
        endif()

        get_filename_component(RELEASE_CONFIG_DIR_NAME ${RELEASE_CONFIG} NAME)
        string(TOLOWER "${RELEASE_CONFIG_DIR_NAME}" RELEASE_CONFIG_DIR_NAME)
        if(RELEASE_CONFIG_DIR_NAME STREQUAL "cmake" AND NOT arg_DO_NOT_DELETE_PARENT_CONFIG_PATH)
            file(REMOVE_RECURSE ${RELEASE_CONFIG})
        else()
            get_filename_component(RELEASE_CONFIG_PARENT_DIR ${RELEASE_CONFIG} DIRECTORY)
            get_filename_component(RELEASE_CONFIG_DIR_NAME ${RELEASE_CONFIG_PARENT_DIR} NAME)
            string(TOLOWER "${RELEASE_CONFIG_DIR_NAME}" RELEASE_CONFIG_DIR_NAME)
            if(RELEASE_CONFIG_DIR_NAME STREQUAL "cmake" AND NOT arg_DO_NOT_DELETE_PARENT_CONFIG_PATH)
                file(REMOVE_RECURSE ${RELEASE_CONFIG_PARENT_DIR})
            endif()
        endif()
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        if(NOT EXISTS "${DEBUG_SHARE}")
            message(FATAL_ERROR "'${DEBUG_SHARE}' 不存在。")
        endif()
    endif()

    file(GLOB_RECURSE UNUSED_FILES
        "${DEBUG_SHARE}/*[Tt]argets.cmake"
        "${DEBUG_SHARE}/*[Cc]onfig.cmake"
        "${DEBUG_SHARE}/*[Cc]onfigVersion.cmake"
        "${DEBUG_SHARE}/*[Cc]onfig-version.cmake"
    )
    if(UNUSED_FILES)
        file(REMOVE ${UNUSED_FILES})
    endif()

    file(GLOB_RECURSE RELEASE_TARGETS
        "${RELEASE_SHARE}/*-release.cmake"
    )
    foreach(RELEASE_TARGET IN LISTS RELEASE_TARGETS)
        file(READ ${RELEASE_TARGET} _contents)
        string(REPLACE "${CURRENT_INSTALLED_DIR}" "\${_IMPORT_PREFIX}" _contents "${_contents}")
        string(REGEX REPLACE "\\\${_IMPORT_PREFIX}/bin/([^ \"]+${EXECUTABLE_SUFFIX})" "\${_IMPORT_PREFIX}/${arg_TOOLS_PATH}/\\1" _contents "${_contents}")
        file(WRITE ${RELEASE_TARGET} "${_contents}")
    endforeach()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(GLOB_RECURSE DEBUG_TARGETS
            "${DEBUG_SHARE}/*-debug.cmake"
            )
        foreach(DEBUG_TARGET IN LISTS DEBUG_TARGETS)
            file(RELATIVE_PATH DEBUG_TARGET_REL "${DEBUG_SHARE}" "${DEBUG_TARGET}")

            file(READ ${DEBUG_TARGET} _contents)
            string(REPLACE "${CURRENT_INSTALLED_DIR}" "\${_IMPORT_PREFIX}" _contents "${_contents}")
            string(REGEX REPLACE "\\\${_IMPORT_PREFIX}/bin/([^ \";]+${EXECUTABLE_SUFFIX})" "\${_IMPORT_PREFIX}/${arg_TOOLS_PATH}/\\1" _contents "${_contents}")
            string(REPLACE "\${_IMPORT_PREFIX}/lib" "\${_IMPORT_PREFIX}/debug/lib" _contents "${_contents}")
            string(REPLACE "\${_IMPORT_PREFIX}/bin" "\${_IMPORT_PREFIX}/debug/bin" _contents "${_contents}")
            file(WRITE ${RELEASE_SHARE}/${DEBUG_TARGET_REL} "${_contents}")

            file(REMOVE ${DEBUG_TARGET})
        endforeach()
    endif()

    #修复 cmake 生成的 targets 和 configs 中的 ${_IMPORT_PREFIX}；
    #由于这些文件可能被重命名，因此必须检查每个 *.cmake 文件
    file(GLOB_RECURSE MAIN_CMAKES "${RELEASE_SHARE}/*.cmake")

    foreach(MAIN_CMAKE IN LISTS MAIN_CMAKES)
        file(READ ${MAIN_CMAKE} _contents)
        #此修正并非对所有情况都正确。要使其对所有情况都正确，需要考虑
        #原始文件夹相对于 CURRENT_PACKAGES_DIR 的深度，与移动后文件夹深度的比较，
        #移动后的深度总是至少（>=）2，例如 share/${PORT}。目前代码假设深度总是 2，尽管
        #此要求仅对 *Config.cmake 成立。targets 不要求与 *Config.cmake 在同一文件夹中！
        if(NOT arg_NO_PREFIX_CORRECTION)
            string(REGEX REPLACE
                "get_filename_component\\(_IMPORT_PREFIX \"\\\${CMAKE_CURRENT_LIST_FILE}\" PATH\\)(\nget_filename_component\\(_IMPORT_PREFIX \"\\\${_IMPORT_PREFIX}\" PATH\\))*"
                "get_filename_component(_IMPORT_PREFIX \"\${CMAKE_CURRENT_LIST_FILE}\" PATH)\nget_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)\nget_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)"
                _contents "${_contents}") # 参见 #1044 了解为何需要此替换。参见 #4782 了解为何必须使用正则表达式。
            string(REGEX REPLACE
                "get_filename_component\\(PACKAGE_PREFIX_DIR \"\\\${CMAKE_CURRENT_LIST_DIR}/\\.\\./(\\.\\./)*\" ABSOLUTE\\)"
                "get_filename_component(PACKAGE_PREFIX_DIR \"\${CMAKE_CURRENT_LIST_DIR}/../../\" ABSOLUTE)"
                _contents "${_contents}")
            string(REGEX REPLACE
                "get_filename_component\\(PACKAGE_PREFIX_DIR \"\\\${CMAKE_CURRENT_LIST_DIR}/\\.\\.((\\\\|/)\\.\\.)*\" ABSOLUTE\\)"
                "get_filename_component(PACKAGE_PREFIX_DIR \"\${CMAKE_CURRENT_LIST_DIR}/../../\" ABSOLUTE)"
                _contents "${_contents}") # 这是一个与 meson 相关的变通方案，参见 https://github.com/mesonbuild/meson/issues/6955
        endif()

        #使用 ${_IMPORT_PREFIX} 修复错误的指向安装目录的绝对路径
        #当 vcpkg 构建的库被直接链接到某个 target 而非使用 imported target 时，
        #会发生此问题。可以在此添加更多逻辑来识别有缺陷的 target 文件。
        #由于在多配置构建中此处的替换总是需要在前方使用生成器表达式，
        #因此匹配应始终至少为 >:${CURRENT_INSTALLED_DIR}。
        #通常应存在以下生成器表达式：
        #\$<\$<CONFIG:DEBUG>:${CURRENT_INSTALLED_DIR}/debug/lib/somelib>
        #和/或
        #\$<\$<NOT:\$<CONFIG:DEBUG>>:${CURRENT_INSTALLED_DIR}/lib/somelib>
        #其中 ${CURRENT_INSTALLED_DIR} 被完全展开
        string(REPLACE "${CURRENT_INSTALLED_DIR}" [[${_IMPORT_PREFIX}]] _contents "${_contents}")
        file(WRITE ${MAIN_CMAKE} "${_contents}")
    endforeach()

    # 如果 /debug/<target_path>/ 为空则移除它。
    file(GLOB_RECURSE REMAINING_FILES "${DEBUG_SHARE}/*")
    if(NOT REMAINING_FILES)
        file(REMOVE_RECURSE ${DEBUG_SHARE})
    endif()

    # 如果 /debug/share/ 为空则移除它。
    file(GLOB_RECURSE REMAINING_FILES "${CURRENT_PACKAGES_DIR}/debug/share/*")
    if(NOT REMAINING_FILES)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
    endif()

    # 修补掉所有剩余的绝对路径引用
    file(TO_CMAKE_PATH "${CURRENT_PACKAGES_DIR}" CMAKE_CURRENT_PACKAGES_DIR)
    file(GLOB CMAKE_FILES ${RELEASE_SHARE}/*.cmake)
    foreach(CMAKE_FILE IN LISTS CMAKE_FILES)
        file(READ ${CMAKE_FILE} _contents)
        string(REPLACE "${CMAKE_CURRENT_PACKAGES_DIR}" "\${CMAKE_CURRENT_LIST_DIR}/../.." _contents "${_contents}")
        file(WRITE ${CMAKE_FILE} "${_contents}")
    endforeach()
endfunction()


