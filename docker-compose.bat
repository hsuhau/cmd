@echo off

echo current dir: %cd%

:: 使用延迟变量
setlocal enabledelayedexpansion

:: 遍历所有参数，如果是 compose 文件则转换路径格式
:: 使用 wslpath 将 Windows 路径转为 wsl 中的路径
for %%i in ( %* ) do (
    :: 当前参数
    set arg=%%i
    :: 使用下面这种方式中文路径不会乱码
    if !last_arg!==-f if !arg! neq -f  set "arg=`wslpath '!arg!'`"
    :: 追加到新的参数列表中
    set "args=!args! !arg!"
    :: 作为上一个参数保存
    set last_arg=%%i
)

:: IDEA 部署到指定 Docker Daemon 的时候会设置下面的环境变量

:: 设置环境变量 DOCKER_HOST 来指定 Docker Daemon 的 URL
if defined DOCKER_HOST set "envs=export DOCKER_HOST=%DOCKER_HOST%;"

:: 设置环境变量 DOCKER_TLS_VERIFY 和 DOCKER_CERT_PATH 指定 TLS 配置
:: DOCKER_CERT_PATH 为空时，wslpath 命令的结果是 '.'，要做处理
if defined DOCKER_CERT_PATH set "envs=%envs%export DOCKER_CERT_PATH=`wslpath '%DOCKER_CERT_PATH%'`;"
set "envs=%envs%export DOCKER_TLS_VERIFY=%DOCKER_TLS_VERIFY%;"

:: 通过 WSL 调用 docker-compose
:: 如果 bash -c 命令参数中包含$则要转义，否则在解析 bash -c 命令的时候就会对 shell 变量进行替换
:: 注意：.env 文件需要在当前命令的执行目录下
bash -c "%envs%env|grep DOCKER;set -x;docker-compose %args%;"