@echo off
cd /d C:\Programming\TestProject
C:\Heights\Miniconda\python.exe pycharm_installer.py

::start "" cmd /k "set PATH=C:\Heights\Miniconda;C:\Heights\Miniconda\Library\mingw-w64\bin;C:\Heights\Miniconda\Library\usr\bin;C:\Heights\Miniconda\Library\bin;C:\Heights\Miniconda\Scripts;C:\WINDOWS\System32\OpenSSH\;%PATH% && cd /d C:\Programming\TestProject && python pycharm_installer.py"

exit /b