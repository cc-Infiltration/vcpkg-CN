if(NOT DEFINED PYTHON_VERSION)
    message(FATAL_ERROR "PYTHON_VERSION 应当已定义。")
endif()

if(NOT DEFINED PYTHON_DIR)
    message(FATAL_ERROR "PYTHON_DIR 应当已定义。")
endif()

# 我们希望能够从这个嵌入式包外部导入内容。
# https://docs.python.org/3/library/sys_path_init.html#pth-files
string(REGEX MATCH "^3\\.[0-9]+" _python_version_plain "${PYTHON_VERSION}")
string(REPLACE "." "" _python_version_plain "${_python_version_plain}")
file(REMOVE "${PYTHON_DIR}/python${_python_version_plain}._pth")

# 由于这个嵌入式包不再被隔离，我们应确保
# 它不会意外地从 Windows 注册表中获取内容。
file(WRITE "${PYTHON_DIR}/sitecustomize.py" [[import os
import sys
sys.path.insert(1, os.path.dirname(os.path.realpath(__file__)))
]])
