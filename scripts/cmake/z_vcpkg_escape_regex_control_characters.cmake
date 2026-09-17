function(z_vcpkg_escape_regex_control_characters out_var string)
    if(ARGC GREATER "2")
        message(FATAL_ERROR "z_vcpkg_escape_regex_control_characters 被传入了多余的参数：${ARGN}")
    endif()
    # 使用 | 代替 [] 以避免混淆；此外，CMake 不支持 `[]` 中的 `]`
    string(REGEX REPLACE [[\[|\]|\(|\)|\.|\+|\*|\^|\\|\$|\?|\|]] [[\\\0]] escaped_content "${string}")
    set("${out_var}" "${escaped_content}" PARENT_SCOPE)
endfunction()
