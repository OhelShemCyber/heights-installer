@echo off
setlocal EnableDelayedExpansion

:: Path to preserve (Miniconda)
set "PRESERVE_DIR=C:\Heights\Miniconda"
set "PYTHON_PATHS="

echo Scanning for python.exe locations...

:: Gather Python parent paths to remove
for /f "delims=" %%P in ('where python 2^>nul') do (
    for %%D in ("%%~dpP") do (
        set "DIR=%%~fD"
        echo !DIR! | find /i "!PRESERVE_DIR!" >nul
        if errorlevel 1 (
            echo Marking for removal: !DIR!
            set "PYTHON_PATHS=!PYTHON_PATHS!;!DIR:~0,-1!"
        ) else (
            echo Preserving our Miniconda: !DIR!
        )
    )
)

:: Trim leading ;
set "PYTHON_PATHS=!PYTHON_PATHS:~1!"

:: ------------------------------
:: Clean USER PATH
:: ------------------------------
echo.
echo Cleaning USER PATH...

set "USER_CLEAN_PATH="
for %%X in (%PATH:;= %) do (
    echo !PYTHON_PATHS! | find /i "%%X" >nul
    if errorlevel 1 (
        if defined USER_CLEAN_PATH (
            set "USER_CLEAN_PATH=!USER_CLEAN_PATH!;%%X"
        ) else (
            set "USER_CLEAN_PATH=%%X"
        )
    ) else (
        echo Removed from USER PATH: %%X
    )
)

if defined USER_CLEAN_PATH (
    echo %USER_CLEAN_PATH%> "%TEMP%\user_clean_path.txt"
    for /f "usebackq delims=" %%A in ("%TEMP%\user_clean_path.txt") do setx PATH %%A
) else (
    echo [WARNING] Cleaned USER PATH would be empty — skipping setx.
)


echo.
echo PATH cleanup complete via temp file and SETX.
::timeout /t 3 >nul
exit /b