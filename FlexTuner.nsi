; FlexTuner.nsi
;
; This script is based on example1.nsi but it remembers the directory, 
; has uninstall support and (optionally) installs start menu shortcuts.
;
; It will install FlexTuner WSLFlow script into a directory that the user selects.
;
; See install-shared.nsi for a more robust way of checking for administrator rights.
; See install-per-user.nsi for a file association example.
;--------------------------------


!define APP_NAME FlexTuner
; The name of the installer
Name "${APP_NAME} test"

; The file to write
OutFile "${APP_NAME}_installer.exe"

; Request application privileges for Windows Vista and higher
RequestExecutionLevel admin

; Build Unicode installer
; Unicode True
!include "MUI2.nsh"
!insertmacro MUI_LANGUAGE "English"

; The default installation directory
InstallDir $PROGRAMFILES\${APP_NAME}

; Registry key to check for directory (so if you install again, it will 
; overwrite the old one automatically)
InstallDirRegKey HKLM "Software\NSIS_${APP_NAME}" "Install_Dir"

;--------------------------------
; Pages

Page components
Page directory
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles

;--------------------------------

; The stuff to install
Section "${APP_NAME} (required)"

  SectionIn RO
  ; Set output path to the installation directory.
  SetOutPath $INSTDIR
  File "windows\run.bat"
  
  ; Put file there
  ; File "example2.nsi"
  ; Set output path to the linux directory within the installation directory
  SetOutPath "$INSTDIR\linux"
  ; Include all files from linux directory
  File "linux\*.*"
  
  ; Set output path to the windows directory within the installation directory
  SetOutPath "$INSTDIR\windows"
  ; Include all files from windows directory
  File "windows\*.*"

  ; Write the installation path into the registry
  WriteRegStr HKLM SOFTWARE\NSIS_FlexTuner "Install_Dir" "$INSTDIR"
  
  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\FlexTuner" "DisplayName" "NSIS FlexTuner"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\FlexTuner" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\FlexTuner" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\FlexTuner" "NoRepair" 1
  WriteUninstaller "$INSTDIR\uninstall.exe"
  
  
  ; Create a shortcut to install_wsl.bat in the Start Menu
  CreateShortcut "$SMPROGRAMS\FlexTuner\Install WSL.lnk" "$INSTDIR\windows\install_wsl.bat"

  ; Convert run.bat to run.exe using Bat To Exe Converter (or similar tool)
  ; Note: You need to have a tool like Bat To Exe Converter installed and accessible in your PATH
  DetailPrint "Converting run.bat to run.exe..."
  nsExec::ExecToLog '"C:\Users\87488\Bat_To_Exe_Converter_x64.exe" /bat "$INSTDIR\run.bat" /exe "$INSTDIR\FlexTuner.exe"'
  DetailPrint "Conversion completed."

  ; Check if run.exe was created
  IfFileExists "$INSTDIR\FlexTuner.exe" 0 +2
  DetailPrint "FlexTuner.exe created successfully."

  ; Optionally, delete the original batch file
  Delete "$INSTDIR\run.bat"
  
  ; Execute install_wsl.bat and wait for it to complete
  ; ExecWait '"$INSTDIR\windows\install_wsl.bat" > NUL 2>&1'
  ExecWait '$INSTDIR\windows\install_wsl.bat'
  ; nsExec::ExecToLog '"$INSTDIR\windows\install_wsl.bat"'
  DetailPrint "wsl installed"
  ; Execute copy_install.bat
  ; Exec "$INSTDIR\windows\copy_install.bat"
  ; nsExec::ExecToLog '"$INSTDIR\windows\copy_install.bat"'
  ExecWait '"$INSTDIR\windows\copy_install.bat"'

  ; ; Execute the batch file and log output to the detail window
  ; ExecDos::exec '"$INSTDIR\windows\copy_install.bat"' "" ""
  ; Pop $0
  ; DetailPrint "ExecDos::exec returned: $0"

  DetailPrint "source installed"
SectionEnd

; Optional section (can be disabled by the user)
Section "Start Menu Shortcuts"

  CreateDirectory "$SMPROGRAMS\FlexTuner"
  CreateShortcut "$SMPROGRAMS\FlexTuner\Uninstall.lnk" "$INSTDIR\uninstall.exe"
  CreateShortcut "$SMPROGRAMS\FlexTuner\FlexTuner (MakeNSISW).lnk" "$INSTDIR\windows\run.bat"

SectionEnd

;--------------------------------

; Uninstaller

Section "Uninstall"
  ; Execute uninstall_wsl.bat and log output to the detail window
  ExecWait '"$INSTDIR\windows\uninstall_wsl.bat"'
  DetailPrint "WSL uninstalled"
  
  ; Remove registry keys
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\FlexTuner"
  DeleteRegKey HKLM SOFTWARE\NSIS_FlexTuner

  ; Remove files and uninstaller
  ; Delete $INSTDIR\example2.nsi
  Delete $INSTDIR\${APP_NAME}.exe
  Delete $INSTDIR\uninstall.exe
  ; Remove all files from linux and windows directories
  RMDir /r $INSTDIR\linux
  RMDir /r $INSTDIR\windows
  ; Remove start menu shortcuts
  Delete "$SMPROGRAMS\FlexTuner\*.lnk"

  ; Remove directories
  RMDir "$SMPROGRAMS\FlexTuner"
  RMDir "$INSTDIR"

SectionEnd
