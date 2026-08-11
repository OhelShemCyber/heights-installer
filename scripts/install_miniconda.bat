@echo off

:: Ensure C:\Heights exists
if not exist "C:\Heights" mkdir "C:\Heights"

:: Download and install Miniconda
curl -o %TEMP%\miniconda.exe https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe

:: Install Miniconda silently to our desired folder
start /wait %TEMP%\miniconda.exe /InstallationType=JustMe /AddToPath=1 /RegisterPython=1 /S /D=C:\Heights\Miniconda

:: Confirm Python is now available
python --version

:done
::timeout /t 3 >nul
exit /b
