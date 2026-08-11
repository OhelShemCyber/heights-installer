@echo off

:: Uninstall Miniconda (if it exists)
::if exist "C:\Heights\Miniconda\Uninstall-Miniconda3.exe" (
::    echo Uninstalling Miniconda...
::    start /wait "" "C:\Heights\Miniconda\Uninstall-Miniconda3.exe" /S /RemoveCaches=1 /RemoveConfigFiles=all /RemoveUserData=1
::)

:: Delete installation folders
::rmdir /s /q C:\Heights
timeout /t 3 >nul
exit /b



