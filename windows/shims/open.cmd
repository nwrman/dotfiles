@echo off
setlocal EnableDelayedExpansion

if "%~1"=="" (
  start "" .
  goto :eof
)

set "arg=%~1"

:: Pass URLs / URI schemes through unchanged
if /i "!arg:~0,7!"=="http://"  goto :launch
if /i "!arg:~0,8!"=="https://" goto :launch
if /i "!arg:~0,6!"=="ftp://"   goto :launch
if /i "!arg:~0,7!"=="file://"  goto :launch
if /i "!arg:~0,7!"=="mailto:"  goto :launch

:: Tilde at start -> %USERPROFILE%
if "!arg!"=="~"          set "arg=%USERPROFILE%"
if "!arg:~0,2!"=="~/"    set "arg=%USERPROFILE%\!arg:~2!"
if "!arg:~0,2!"=="~\"    set "arg=%USERPROFILE%\!arg:~2!"

:: /mnt/c/... -> C:\... (WSL-style paths users sometimes paste)
if /i "!arg:~0,7!"=="/mnt/c/" set "arg=C:\!arg:~7!"
if /i "!arg:~0,7!"=="/mnt/d/" set "arg=D:\!arg:~7!"

:: Forward slashes -> backslashes
set "arg=!arg:/=\!"

:launch
start "" "!arg!" >nul 2>&1
endlocal
