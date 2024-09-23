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
 
!define MUI_PAGE_CUSTOMFUNCTION_PRE SkipPageInPhase2
!insertmacro MUI_PAGE_WELCOME
!define MUI_PAGE_CUSTOMFUNCTION_PRE SkipPageInPhase2
!insertmacro MUI_PAGE_COMPONENTS
!define MUI_PAGE_CUSTOMFUNCTION_PRE SkipPageInPhase2
!insertmacro MUI_PAGE_DIRECTORY
!define MUI_PAGE_CUSTOMFUNCTION_PRE ConfigurePhaseSections
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_LANGUAGE "English"
 
 
Section "Phase1: Required" SID_P11
SectionIn RO
DetailPrint P1.1
SetOutPath "$INSTDIR\linux"
File /r "linux\*.*"
SetOutPath "$INSTDIR\windows"
File "windows\*.*"
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
ExecWait '"$SYSDIR\dism.exe" /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart'
ExecWait '"$SYSDIR\dism.exe" /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart'

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
ExecWait '$INSTDIR\windows\per.bat'
DetailPrint "wsl installed"
Sleep 2000
DetailPrint "copying install"
ExecWait '"$INSTDIR\windows\copy_install.bat"'
SectionEnd
 
Section "Uninstall"
  ExecWait '"$INSTDIR\windows\uninstall_wsl.bat"'
  DetailPrint "WSL uninstalled"

  Delete "$SMPROGRAMS\${APP_NAME}\asus-llm.lnk"
  RMDir "$SMPROGRAMS\${APP_NAME}"
  Delete "$DESKTOP\asus-llm.lnk"

  Delete "$INSTDIR\uninstall.exe"
  RMDir /r "$INSTDIR\windows"
  RMDir /REBOOTOK "$INSTDIR\scripts\llama-factory"
  
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

