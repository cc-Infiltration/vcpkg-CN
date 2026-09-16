function(vcpkg_clean_msbuild)
    if(NOT ARGC EQUAL 0)
        message(WARNING "vcpkg_clean_msbuild 传入了多余的参数：${ARGV}")
    endif()
    file(REMOVE_RECURSE
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
    )
endfunction()
