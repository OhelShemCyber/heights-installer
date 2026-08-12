@echo off
setlocal

set "LOG=C:\Heights\install_log.txt"

if not exist "C:\Heights" mkdir "C:\Heights" 2>nul

>> "%LOG%" echo(
>> "%LOG%" echo ============================================================
>> "%LOG%" echo PyCharm setup started - %DATE% %TIME%
>> "%LOG%" echo ============================================================

cd /d C:\Programming\TestProject

echo.
echo  ============================================================
echo   Setting up PyCharm Community
echo   This downloads about 900 MB and takes several minutes.
echo   Progress appears below. Full log: %LOG%
echo  ============================================================
echo.

rem No redirection here - output must stay live in this window, otherwise it
rem sits blank for the whole download. pycharm_installer.py appends to the log
rem itself. -X utf8 keeps non-ASCII output safe if this is ever piped.
C:\Heights\Miniconda\python.exe -X utf8 pycharm_installer.py
set RC=%ERRORLEVEL%

>> "%LOG%" echo [exit code %RC%]

if not "%RC%"=="0" (
    echo.
    echo [ERROR] PyCharm setup failed with exit code %RC%.
    echo         Full log: %LOG%
    echo         Please show this window to your instructor.
    pause
)

::start "" cmd /k "set PATH=C:\Heights\Miniconda;C:\Heights\Miniconda\Library\mingw-w64\bin;C:\Heights\Miniconda\Library\usr\bin;C:\Heights\Miniconda\Library\bin;C:\Heights\Miniconda\Scripts;C:\WINDOWS\System32\OpenSSH\;%PATH% && cd /d C:\Programming\TestProject && python pycharm_installer.py"

exit /b %RC%
