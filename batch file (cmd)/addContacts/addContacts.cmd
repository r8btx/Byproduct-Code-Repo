:: WARNING! Modifying Windows registry may result in serious damage! Proceed with caution!
:: The author of this code is not responsible for any harm caused by the use of this code.

:: This script adds given contact information to Windows registry, which will then be shown after system boot before log on.
:: Used techniques: user input, (pseudo) string sanitization, output text-based file, edit Windows registry,  etc.

@echo off
pushd %~dp0

rem Attain permission necessary for editing registry values
call :elevate || exit /b 1

rem Ask for user input
:ask
cls
set /p s1=What is your email address? ^> 
set /p s2=What is your phone number? ^> 

rem Confirm the input. Use pseudo input sanitization.
echo.
echo.Your email: "%s1:"=%"
echo.Your phone number: "%s2:"=%"
echo.
echo.Type "Confirm" if your information is correct.
echo.Type anything else if you want to re-enter your information.
set /p confirm=^> 
if /i "%confirm:"=%" neq "confirm" goto :ask

rem Create helper VBS
set regAddress=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System
set f="%temp%\vbsHelper%random%.vbs"
echo.set WSHShell = CreateObject("WScript.Shell") >"%f%"
echo.WSHShell.RegWrite "%regAddress%\legalnoticecaption", "Contact Information", "REG_SZ" >>"%f%"
echo.WSHShell.RegWrite "%regAddress%\legalnoticetext", ""^&vbLf^&"%s1:"=%"^&vbLf^&"%s2:"=%", "REG_SZ" >>"%f%"

rem Call and remove VBS
call "%f%" & del "%f%"

rem Display registry value
cls
echo.The following information is registered:
reg query "%regAddress%" /v "legalnoticetext" | more +3

echo.End of File.
pause
exit /b

::End of main----------------------------------------------------------------------------------------------------::

:elevate
whoami /groups |find " S-1-16-12288 " >nul 2>&1 && exit /b 0
echo.To edit Windows registry, admin privilege is required.
echo.Requesting administrative privilege...
powershell Start-Process "%~s0" -Verb runAs
if %ErrorLevel% neq 0 echo.User denied the request. && pause && exit /b 1
exit /b 2
