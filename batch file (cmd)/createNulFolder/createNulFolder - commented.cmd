exit /b
rem This file is not for execution. search <::> for annotated messages
:: This script creates a folder named "nul", which is normally disallowed in Windows environment.
:: Then, the script changes nul folder's properties.
:: Used techniques: argument passing, privilege elevation, symbolic link creation, conditional execution (&&, ||), etc.

@echo off
pushd %~dp0       <::> this allows the script to work on where it is executed instead of system32 folder even if the script is executed with admin privilege

rem To delete nul folder, remove two colons(::) from the below line
::goto :deleteNul

rem To create a symbolic link to nul folder, remove two colons(::) from the below line
::goto :createSymLink

rem Create nul folder
mkdir "\\.\%~dp0nul" 2>nul       <::> 2>nul suppresses error message. 

rem Create desktop.ini for nul folder's icon image
call :writeIni "[.ShellClassInfo]"       & rem differenciate call and goto. call will return, but goto will not.
call :writeIni "IconResource=C:\WINDOWS\system32\imageres.dll,54"       <::> use double quote to pass arguments with special characters
call :writeIni "LocalizedResourceName=! Placeholder"

rem Add "hidden" and "system" attribute to nul folder
rem If this doesn't work, create a symbolic link and apply attributes through the link
attrib +h +s "\\.\%~dp0nul"




echo.End of File.
pause
exit /b       <::> /b argument will exit the script instead of cmd process

::End of main----------------------------------------------------------------------------------------------------::

:deleteNul
rd Link2nul >nul 2>&1       <::> >nul 2>&1 suppresses all resulting messages
rd /s /q "\\.\%~dp0nul" && echo.Removal complete. && pause && exit /b 0       <::> if successful, exit with 0
exit /b 1       <::> if unsuccessful, exit with 1

:createSymLink
if not exist "nul\" exit /b 1
call :elevate || exit /b 1       <::> exit with code 1 if :elevate fails
mklink /d "Link2nul" "\\.\%~dp0nul" && pause && exit /b 0       <::> creates symbolic link of nul folder. needs admin privilege.
exit /b 1

:writeIni
echo.%~1>>"\\.\%~dp0nul\desktop.ini"       <::> %~i removes surrounding quotes from the argument i
exit /b

:elevate
whoami /groups |find " S-1-16-12288 " >nul 2>&1 && exit /b 0       <::> if admin privilege is detected, exit with 0
echo.To create a symbolic link, admin privilege is required.
echo.Requesting administrative privilege...
powershell Start-Process "%~s0" -Verb runAs       <::> attempts to execute self with elevated privilege
if %ErrorLevel% neq 0 echo.User denied the request. && pause && exit /b 1       <::> if elevation is denied, exit with 1
exit /b 2       <::> if elevation is approved, exit with 2