
RequestExecutionLevel Admin
!define APP_NAME FlexTuner
Name "${APP_NAME}"
!define COMPANYNAME "asus-llm"
OutFile "${APP_NAME}_installer.exe"
InstallDir "$ProgramFiles\Test-${APP_NAME}"
ShowInstDetails Show
!define SETUPID "$(^Name)" ; TODO: Replace with a GUID from guidgen.com
 
Var Phase
 
!include MUI2.nsh
!include Sections.nsh
!include FileFunc.nsh
 
Function .onInit
${GetParameters} $0
ClearErrors
${GetOptions} $0 "/Phase2" $1
${IfNotThen} ${Errors} ${|} StrCpy $Phase 2 ${|}
 
IfSilent "" +2
	Call ConfigurePhaseSections
FunctionEnd
 
Function SkipPageInPhase2
${IfThen} $Phase >= 2 ${|} Abort ${|}
FunctionEnd
!define MUI_ICON "icons\icon.ico"
!define MUI_PAGE_CUSTOMFUNCTION_PRE SkipPageInPhase2
!define MUI_WELCOMEFINISHPAGE_BITMAP "icons\asus-logo-photo-by-llexandro-19.bmp"
; !define MUI_WELCOMEFINISHPAGE_BITMAP_NOSTRETCH
!insertmacro MUI_PAGE_WELCOME
; !insertmacro MUI_PAGE_LICENSE "LICENSE.electron.txt"
!define MUI_PAGE_CUSTOMFUNCTION_PRE SkipPageInPhase2
!insertmacro MUI_PAGE_COMPONENTS
!define MUI_PAGE_CUSTOMFUNCTION_PRE SkipPageInPhase2
!insertmacro MUI_PAGE_DIRECTORY
!define MUI_PAGE_CUSTOMFUNCTION_PRE ConfigurePhaseSections
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_LANGUAGE "English"
LangString DESC_Section1 ${LANG_ENGLISH} "This is required to install pre-installed components"
LangString DESC_Section2 ${LANG_ENGLISH} "This is an optional component for installation"
LangString DESC_Section3 ${LANG_ENGLISH} "This is a required component for installation"
 
Section "Phase1: Required" SID_P11
SectionIn RO
DetailPrint P1.1
SetOutPath "$INSTDIR\windows"
File "windows\*.*"
; P1.1 check ASUS-Workbench Conflict
nsExec::ExecToLog /OEM '$INSTDIR\windows\check_conflict.bat'
Pop $4
StrCmp $4 409 0 +10 ;If it is not 409
DetailPrint "Return value: $4"
MessageBox MB_OKCANCEL "ASUS-Workbench Distro is already installed, please uninstall it before proceeding with the installation." IDOK +2
  Quit
; read
ReadRegStr $4 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${SETUPID}" "InstallLocation"
  DetailPrint "uninstall local: $4"
  StrCmp $4 "" +3 0 ; quit if not found
  IfFileExists "$4\uninstall.exe" 0 +2
  ExecWait '"$4\uninstall.exe"'
Quit
; If it is not 409, continue the installation
SetOutPath "$INSTDIR\linux"
File /r "linux\*.*"
SetOutPath "$INSTDIR\scripts\llama-factory"
File /r "llama-factory\*.*"
SetOutPath "$INSTDIR"
File "wsl_update_x64.msi"
File "wsl.exe"
File "asus-llm.exe"

Sleep 1000
SetRebootFlag True ; Pretend we did something that requires a reboot
SectionEnd
 
Section "Phase1: Optional" SID_P12
DetailPrint P1.2
Sleep 2000
SectionEnd
 
Section "-ConfigureRebootAndContinue" SID_P1LAST
StrCpy $0 $ExePath 1 1
${If} $0 == ':'
	StrCpy $0 $ExePath
${Else}
	StrCpy $0 "$WinDir\Temp"
	CreateDirectory "$0"
	StrCpy $0 "$0\${SETUPID}.exe"
	FileOpen $1 $0 w ; Make sure file exists to trigger a file copy instead of a directory copy
	FileClose $1
	CopyFiles /Silent /FilesOnly $ExePath "$0" ; A UNC path might not be available after a reboot, copy the setup to a local path
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\RunOnceEx\${SETUPID}" "2" '||"$SysDir\rundll32.exe" "$SysDir\advpack.dll",DelNodeRunDLL32 "$0"'
${EndIf}

DetailPrint "MWSL"
nsExec::ExecToLog '"$SYSDIR\dism.exe" /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart'
nsExec::ExecToLog '"$SYSDIR\dism.exe" /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart'

DetailPrint "Downloading Ubuntu Jammy WSL image..."
nsisdl::download "https://cloud-images.ubuntu.com/wsl/releases/jammy/current/ubuntu-jammy-wsl-amd64-wsl.rootfs.tar.gz" "$TEMP\ubuntu-jammy-wsl-amd64-wsl.rootfs.tar.gz"
Pop $4
${If} $4 == "success"
    DetailPrint "Download successful."
${Else}
    DetailPrint "Download failed: $4"
    Abort
${EndIf}

WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\RunOnceEx\${SETUPID}" "" "$(^Name)"
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\RunOnceEx\${SETUPID}" "1" '||"$0" /Phase2'

WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${SETUPID}" "DisplayName" "${APP_NAME}"
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${SETUPID}" "UninstallString" "$INSTDIR\uninstall.exe"
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${SETUPID}" "InstallLocation" "$INSTDIR"
; WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${SETUPID}" "DisplayIcon" "$INSTDIR\${APP_NAME}.exe"
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${SETUPID}" "Publisher" "Your Company Name"
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${SETUPID}" "DisplayVersion" "1.0"
WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${SETUPID}" "NoModify" 1
WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${SETUPID}" "NoRepair" 1
WriteUninstaller "$INSTDIR\uninstall.exe"

CreateDirectory "$LOCALAPPDATA\ASUSLLm\AIDistro"
; Start Menu
CreateDirectory "$SMPROGRAMS\${APP_NAME}"
; SetOutPath "$SMPROGRAMS\${APP_NAME}"
CreateShortCut "$SMPROGRAMS\${APP_NAME}\asus-llm.lnk" "$INSTDIR\asus-llm.exe" "" "$INSTDIR\asus-llm.exe" 0 SW_SHOWNORMAL ALT|CONTROL|F5 "a description about asus-llm"
CreateShortCut "$DESKTOP\asus-llm.lnk" "$INSTDIR\asus-llm.exe" "" "$INSTDIR\asus-llm.exe" 0 SW_SHOWNORMAL ALT|CONTROL|F5 "a description about asus-llm"
SectionEnd

Section "Phase2: Required" SID_P21
SectionIn RO
DetailPrint P2.1
DetailPrint "P2.1 wsl_update.msi"
ExecWait '"$SYSDIR\msiexec.exe" /i "$INSTDIR\wsl_update_x64.msi" /qn /norestart'
Sleep 2000
; ExecWait '"$INSTDIR\wsl.exe" --set-default-version 2'
nsExec::ExecToLog '"$INSTDIR\wsl.exe" --set-default-version 2'
Sleep 2000
nsExec::ExecToLog '"$INSTDIR\wsl.exe" --update'
Sleep 2000
DetailPrint "P2.1 wsl"
; P2.1-P1.1 double-check ASUS-Workbench Conflict
nsExec::ExecToLog /OEM '$INSTDIR\windows\check_conflict.bat'
Pop $4
StrCmp $4 409 0 +4
DetailPrint "Return value: $4"
MessageBox MB_OK "ASUS-Workbench Distro is already installed, please uninstall it before proceeding with the installation."
Quit
; ExecWait '$INSTDIR\windows\per.bat'
nsExec::ExecToLog /OEM '$INSTDIR\windows\per.bat'
Pop $4
StrCmp $4 0 +3
DetailPrint "       Return value: $4"
Abort "Exec per.bat failed."

DetailPrint "wsl installed"
Sleep 2000
DetailPrint "Setup and install"
nsExec::ExecToLog /OEM '"$INSTDIR\windows\copy_install.bat"'
Pop $4
StrCmp $4 0 +3
DetailPrint "       Return value: $4"
Abort "Exec copy_install.bat failed."
SectionEnd

Section "Uninstall"
  nsExec::ExecToLog /OEM '"$INSTDIR\windows\uninstall_wsl.bat"'
  DetailPrint "WSL uninstalled"

  Delete "$SMPROGRAMS\${APP_NAME}\asus-llm.lnk"
  RMDir "$SMPROGRAMS\${APP_NAME}"
  Delete "$DESKTOP\asus-llm.lnk"
  Delete "$TEMP\ubuntu-jammy-wsl-amd64-wsl.rootfs.tar.gz"
  Delete "$INSTDIR\uninstall.exe"
  RMDir /r "$INSTDIR\windows"
  RMDir /REBOOTOK "$INSTDIR\scripts\llama-factory"
  RMDir /r "$LOCALAPPDATA\ASUSLLm\AIDistro"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${SETUPID}"
  
  Delete "$DESKTOP\${APP_NAME}.lnk"
  Delete "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk"
  RMDir "$SMPROGRAMS\${APP_NAME}"
  RMDir /r "$INSTDIR"
SectionEnd

Function ConfigurePhaseSections
${If} $Phase >= 2
	StrCpy $1 ${SID_P11} ; Disable first
	StrCpy $2 ${SID_P1LAST} ; Disable last
${Else}
	StrCpy $1 ${SID_P21}
	StrCpy $2 ${SID_P21}
${EndIf}
loop:
	${If} $1 <= $2
		!insertmacro UnselectSection $1
		IntOp $1 $1 + 1
		Goto loop
	${EndIf}
FunctionEnd

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
!insertmacro MUI_DESCRIPTION_TEXT ${SID_P11} $(DESC_Section1)
!insertmacro MUI_DESCRIPTION_TEXT ${SID_P12} $(DESC_Section2)
!insertmacro MUI_DESCRIPTION_TEXT ${SID_P21} $(DESC_Section3)
!insertmacro MUI_FUNCTION_DESCRIPTION_END
