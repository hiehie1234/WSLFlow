RequestExecutionLevel Admin
!define APP_NAME NSIS-FlexTuner
Name "${APP_NAME}"
OutFile "${APP_NAME}_copy.exe"
InstallDir "$ProgramFiles\NSIS-Test-${APP_NAME}"
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
SetOutPath "$INSTDIR\scripts\llama-factory"
File /r "llama-factory\*.*"
SetOutPath "$INSTDIR\windows"
; Include all files from windows directory
File "windows\*.*"
Sleep 1000
SectionEnd
 
Section "Phase1: Optional" SID_P12
DetailPrint P1.2
Sleep 2000
SectionEnd
 
Section "-ConfigureRebootAndContinue" SID_P1LAST
DetailPrint "P1.LAST copy"
DetailPrint "copying install"
ExecWait '"$INSTDIR\windows\copy_install.bat"'
SectionEnd
 
Section "Phase2: Required" SID_P21
SectionIn RO
DetailPrint P2.2
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

