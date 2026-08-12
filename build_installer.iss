[Setup]
PrivilegesRequired=lowest
AppName=Python Setup for Heights
AppVersion=1.0
DefaultDirName={localappdata}\Heights
DefaultGroupName=Heights Python Tools
UninstallDisplayIcon={app}\Heights.ico
SetupIconFile=Heights.ico
OutputDir=.
OutputBaseFilename=HeightsInstaller
Compression=lzma
SolidCompression=yes
SetupLogging=yes
DisableDirPage=yes
DisableReadyPage=yes
DisableFinishedPage=yes
AlwaysRestart=no
RestartIfNeededByRun=no


VersionInfoVersion=1.0.0.0
VersionInfoCompany=OSHHACK
VersionInfoDescription=Python Setup for Heights
VersionInfoProductName=Python Setup for Heights
VersionInfoCopyright=Copyright © 2025 OSHHACK

[Files]
Source: "Heights.ico"; DestDir: "{app}"; Flags: ignoreversion
Source: "HeightsInstaller_Readme.md"; DestDir: "C:\Heights\"; DestName: "README.md"; Flags: ignoreversion
Source: "scripts\\setup_dirs.bat"; DestDir: "{tmp}"; Flags: ignoreversion
Source: "scripts\clean_path.bat"; DestDir: "{tmp}"; Flags: ignoreversion
Source: "scripts\\install_miniconda.bat"; DestDir: "{tmp}"; Flags: ignoreversion
Source: "scripts\\install_packages.bat"; DestDir: "{tmp}"; Flags: ignoreversion
Source: "scripts\\install_pycharm.bat"; DestDir: "{tmp}"; Flags: ignoreversion
Source: "scripts\\launch_tester.bat"; DestDir: "{tmp}"; Flags: ignoreversion
Source: "scripts\\uninstall_cleanup.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "test_project\\*"; DestDir: "C:\\Programming\\TestProject"; Flags: ignoreversion recursesubdirs createallsubdirs

[Run]
; Setup Dirs
Filename: "{tmp}\\setup_dirs.bat"; StatusMsg: "Setting Up Dirs..."; Flags: runhidden waituntilterminated

; Remove Old Python From Path
Filename: "{tmp}\clean_path.bat"; StatusMsg: "Making Sure Miniconda3 Will Be Your Default Python..."; Flags: runhidden waituntilterminated

; Download Miniconda
;Filename: "cmd.exe"; Parameters: "/c curl -o C:\Heights\miniconda.exe https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe"; StatusMsg: "Downloading Miniconda, please wait..."; Flags: runhidden waituntilterminated

; Install Miniconda directly
;Filename: "C:\\Heights\\miniconda.exe"; Parameters: "/InstallationType=JustMe /AddToPath=1 /RegisterPython=1 /S /D=C:\Heights\Miniconda"; StatusMsg: "Installing Miniconda (its not frozen its just thinking)..."; Flags: runhidden waituntilterminated

Filename: "{tmp}\install_miniconda.bat"; StatusMsg: "Installing Miniconda (its not frozen its just thinking)..."; Flags: runhidden waituntilterminated

; Install Python Packages
Filename: "{tmp}\\install_packages.bat"; StatusMsg: "Installing Python Packages..."; Flags: runhidden waituntilterminated

; Install Pycharm Community
;Filename: "cmd.exe"; StatusMsg: "Installing PyCharm..."; Parameters: "/c set PATH=C:\Heights\Miniconda;C:\Heights\Miniconda\Scripts;%PATH% && C:\Heights\Miniconda\python.exe C:\Programming\TestProject\pycharm_installer.py"; Flags: runhidden waituntilterminated
Filename: "{tmp}\\install_pycharm.bat"; StatusMsg: "Installing PyCharm Community (if pro exists does nothing)..."; Flags: waituntilterminated

; Run Python Tester Script
Filename: "{tmp}\\launch_tester.bat"; StatusMsg: "Running Tester..."; Flags: runhidden skipifdoesntexist

[UninstallRun]
Filename: "{app}\\uninstall_cleanup.bat"; RunOnceId: cleanup_miniconda

[Icons]
Name: "{group}\Uninstall Heights Tools"; Filename: "{uninstallexe}"
