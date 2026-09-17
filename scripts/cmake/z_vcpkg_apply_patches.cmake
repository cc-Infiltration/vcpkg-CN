function(z_vcpkg_apply_patches)
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "QUIET" "SOURCE_PATH" "PATCHES")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "内部错误：z_vcpkg_apply_patches 被传入了多余的参数：${arg_UNPARSED_ARGUMENTS}")
    endif()

    find_program(GIT NAMES git git.cmd REQUIRED)
    if(DEFINED ENV{GIT_CONFIG_NOSYSTEM})
        set(git_config_nosystem_backup "$ENV{GIT_CONFIG_NOSYSTEM}")
    else()
        unset(git_config_nosystem_backup)
    endif()

    set(ENV{GIT_CONFIG_NOSYSTEM} 1)
    set(patchnum 0)
    foreach(patch IN LISTS arg_PATCHES)
        get_filename_component(absolute_patch "${patch}" ABSOLUTE BASE_DIR "${CURRENT_PORT_DIR}")
        message(STATUS "正在应用补丁 ${patch}")
        set(logname "patch-${TARGET_TRIPLET}-${patchnum}")
        vcpkg_execute_in_download_mode(
            COMMAND "${GIT}" -c core.longpaths=true -c core.autocrlf=false -c core.filemode=true --work-tree=. --git-dir=.git apply "${absolute_patch}" --ignore-whitespace --whitespace=nowarn --verbose
            OUTPUT_FILE "${CURRENT_BUILDTREES_DIR}/${logname}-out.log"
            ERROR_VARIABLE error
            WORKING_DIRECTORY "${arg_SOURCE_PATH}"
            RESULT_VARIABLE error_code
        )
        file(WRITE "${CURRENT_BUILDTREES_DIR}/${logname}-err.log" "${error}")

        if(error_code)
            if(arg_QUIET)
                message(STATUS "应用补丁 ${patch} - 失败已被静默处理")
            else()
                message(FATAL_ERROR "应用补丁失败：${error}")
            endif()
        endif()

        math(EXPR patchnum "${patchnum} + 1")
    endforeach()
    if(DEFINED git_config_nosystem_backup)
        set(ENV{GIT_CONFIG_NOSYSTEM} "${git_config_nosystem_backup}")
    else()
        unset(ENV{GIT_CONFIG_NOSYSTEM})
    endif()
endfunction()
