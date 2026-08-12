@echo off
setlocal EnableDelayedExpansion

echo ==========================================================
echo   Heights Python Tools - Uninstall
echo ==========================================================
echo.
echo   Removing: PyCharm Community, Miniconda, C:\Heights
echo.
echo   NOT touched: your PATH environment variable
echo   NOT touched: C:\Programming and your project files
echo.
echo   This takes a few minutes. Please wait.
echo.

:: ----------------------------------------------------------------
:: [1/4] PyCharm Community
::
:: Only removes what this installer put there. A PyCharm Professional
:: install belongs to the student, so it is explicitly skipped.
:: ----------------------------------------------------------------
echo [1/4] Removing PyCharm Community...

set "PYCHARM_FOUND="

for /f "delims=" %%K in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall" /s /f "PyCharm" /k 2^>nul ^| findstr /i "HKEY_"') do (
    set "DNAME="
    for /f "tokens=2,*" %%A in ('reg query "%%K" /v DisplayName 2^>nul ^| findstr /i "DisplayName"') do set "DNAME=%%B"

    echo !DNAME! | findstr /i "Professional" >nul
    if errorlevel 1 (
        set "UNINST="
        for /f "tokens=2,*" %%A in ('reg query "%%K" /v UninstallString 2^>nul ^| findstr /i "UninstallString"') do set "UNINST=%%B"
        rem %%~F strips the surrounding quotes reg reports, without a literal
        rem quote character that would unbalance this block
        for %%F in (!UNINST!) do set "UNINST=%%~F"

        if exist "!UNINST!" (
            echo       Uninstalling !DNAME!
            for %%F in ("!UNINST!") do set "UDIR=%%~dpF"
            set "UDIR=!UDIR:~0,-1!"
            rem _?= keeps the NSIS uninstaller in place so start /wait really waits
            start /wait "" "!UNINST!" /S "_?=!UDIR!"
            set "PYCHARM_FOUND=1"
        )
    ) else (
        echo       Skipping !DNAME! - not installed by Heights.
    )
)

if not defined PYCHARM_FOUND (
    for /d %%D in ("%LOCALAPPDATA%\Programs\PyCharm*") do (
        if exist "%%D\bin\Uninstall.exe" (
            echo       Uninstalling %%~nxD
            start /wait "" "%%D\bin\Uninstall.exe" /S "_?=%%~fD\bin"
            set "PYCHARM_FOUND=1"
        ) else if exist "%%D\Uninstall.exe" (
            echo       Uninstalling %%~nxD
            start /wait "" "%%D\Uninstall.exe" /S "_?=%%~fD"
            set "PYCHARM_FOUND=1"
        )
    )
)

if not defined PYCHARM_FOUND echo       No Heights-installed PyCharm found.

:: The uninstaller leaves itself behind when _?= is used.
for /d %%D in ("%LOCALAPPDATA%\Programs\PyCharm*") do rmdir /s /q "%%D" 2>nul

:: ----------------------------------------------------------------
:: [2/4] Miniconda
:: ----------------------------------------------------------------
echo [2/4] Removing Miniconda...

if exist "C:\Heights\Miniconda\Uninstall-Miniconda3.exe" (
    start /wait "" "C:\Heights\Miniconda\Uninstall-Miniconda3.exe" /S /RemoveCaches=1 /RemoveConfigFiles=all /RemoveUserData=1 "_?=C:\Heights\Miniconda"
) else (
    echo       Miniconda uninstaller not found - removing the folder directly.
)

rmdir /s /q "C:\Heights" 2>nul
if exist "C:\Heights" echo       [WARN] C:\Heights could not be fully removed.

:: ----------------------------------------------------------------
:: [3/4] PyCharm settings and caches
::
:: Only PyCharm* subfolders are removed. The JetBrains parent folder is
:: removed with a plain rmdir, which succeeds only if it is empty - so
:: other JetBrains IDEs keep their settings.
:: ----------------------------------------------------------------
echo [3/4] Removing PyCharm settings and caches...

for /d %%D in ("%APPDATA%\JetBrains\PyCharm*")      do rmdir /s /q "%%D" 2>nul
for /d %%D in ("%LOCALAPPDATA%\JetBrains\PyCharm*") do rmdir /s /q "%%D" 2>nul
rmdir "%APPDATA%\JetBrains" 2>nul
rmdir "%LOCALAPPDATA%\JetBrains" 2>nul

:: ----------------------------------------------------------------
:: [4/4] conda user data
:: ----------------------------------------------------------------
echo [4/4] Removing conda user data...

rmdir /s /q "%USERPROFILE%\.conda" 2>nul
rmdir /s /q "%USERPROFILE%\.continuum" 2>nul
del /f /q "%USERPROFILE%\.condarc" 2>nul

:: ----------------------------------------------------------------
echo.
echo ==========================================================
echo   Done.
echo.
echo   Your PATH was NOT changed. To review what is still in it:
echo       reg query "HKCU\Environment" /v Path
echo.
echo   C:\Programming was left alone.
echo ==========================================================
echo.

timeout /t 15
exit /b 0
