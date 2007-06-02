;---------------------------------
; $Id: $
; 
; Vidalia/Tor/Privoxy Bundle Installer
; See BUNDLE_LICENSE for licensing information
;---------------------------------
!include "MUI.nsh"

SetCompressor /SOLID lzma
!packhdr header.dat "upx --best header.dat"

;---------------------------------
; Global definitions
!define SF_SELECTED   1
!define SECTION_OFF   0xFFFFFFFE

!define VIDALIA_NAME        "Vidalia"
!define VIDALIA_EXEC        "vidalia.exe"
!define VIDALIA_APPVERSION  "0.0.13-svn"
!define VIDALIA_DESC        "${VIDALIA_NAME} ${VIDALIA_APPVERSION}"

!define TOR_NAME            "Tor"
!define TOR_EXEC            "tor.exe"
!define TOR_APPVERSION      "0.2.0.1-alpha"
!define TOR_DESC            "${TOR_NAME} ${TOR_APPVERSION}"

!define PRIVOXY_NAME        "Privoxy"
!define PRIVOXY_EXEC        "privoxy.exe"
!define PRIVOXY_APPVERSION  "3.0.6"
!define PRIVOXY_DESC        "${PRIVOXY_NAME} ${PRIVOXY_APPVERSION}"

!define TORBUTTON_NAME      "Torbutton"
!define TORBUTTON_APPVERSION "1.0.4-fx+tb"
!define TORBUTTON_DESC      "${TORBUTTON_NAME} ${TORBUTTON_APPVERSION}"

!define OPENSSL_NAME        "OpenSSL"
!define OPENSSL_APPVERSION  "0.9.8d"
!define OPENSSL_DESC        "${OPENSSL_NAME} ${OPENSSL_APPVERSION}"

!define BUNDLE_NAME         "Vidalia Bundle"
!define BUNDLE_APPVERSION   "${TOR_APPVERSION}-${VIDALIA_APPVERSION}"
!define BUNDLE_REVISION     "1"
!define BUNDLE_PRODVERSION  "0.0.13.${BUNDLE_REVISION}" ; Product version must be x.x.x.x
!define BUNDLE_DESC         "${BUNDLE_NAME} ${BUNDLE_APPVERSION}"
!define INSTALLFILE         "vidalia-bundle-${BUNDLE_APPVERSION}.exe"
!define UNINSTALLER         "Uninstall.exe"
!define SHORTCUTS           "$SMPROGRAMS\${BUNDLE_NAME}"

;--------------------------------
; Installer file details
VIAddVersionKey "ProductName"     "${BUNDLE_NAME}"
VIAddVersionKey "Comments"        "${BUNDLE_DESC}"
VIAddVersionKey "FileVersion"     "${BUNDLE_APPVERSION}"
VIAddVersionKey "FileDescription" "${BUNDLE_DESC}"
VIProductVersion "${BUNDLE_PRODVERSION}"

;--------------------------------
; Basic installer information
Name            "${BUNDLE_NAME}"
Caption         "$(BundleSetupCaption)"
BrandingText    "${BUNDLE_DESC} (Rev. ${BUNDLE_REVISION})"
OutFile         "${INSTALLFILE}"
InstallDir      "$PROGRAMFILES\Vidalia Bundle"
InstallDirRegKey HKCU "Software" "${BUNDLE_NAME}"
SetOverWrite    ifnewer
AutoCloseWindow false
ShowInstDetails show
CRCCheck        on
XPStyle         on

;--------------------------------
; MUI Options
!define MUI_WELCOMEPAGE_TITLE "$(BundleWelcomeTitle)"
!define MUI_WELCOMEPAGE_TEXT  "$(BundleWelcomeText)"
!define MUI_ABORTWARNING
!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\win-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\win-uninstall.ico"
!define MUI_HEADERIMAGE_BITMAP "${NSISDIR}\Contrib\Graphics\Header\win.bmp"
!define MUI_HEADERIMAGE
!define MUI_FINISHPAGE_TEXT "$(BundleFinishText)"
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_FUNCTION CustomFinishFn
!define MUI_FINISHPAGE_RUN_TEXT "$(BundleRunNow)"
!define MUI_FINISHPAGE_LINK "$(BundleLinkText)"
!define MUI_FINISHPAGE_LINK_LOCATION  "http://tor.eff.org/docs/tor-doc-win32.html"

;--------------------------------
; Pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_COMPONENTS
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

;--------------------------------
; Available languages
!insertmacro MUI_LANGUAGE "Dutch"
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "Farsi"
!insertmacro MUI_LANGUAGE "Finnish"
!insertmacro MUI_LANGUAGE "French"
!insertmacro MUI_LANGUAGE "German"
!insertmacro MUI_LANGUAGE "Polish"
!insertmacro MUI_LANGUAGE "PortugueseBR"
!insertmacro MUI_LANGUAGE "Russian"
!insertmacro MUI_LANGUAGE "Spanish"
!insertmacro MUI_LANGUAGE "SimpChinese"
!insertmacro MUI_LANGUAGE "TradChinese"
!include "vidalia_de.nsh"
!include "vidalia_en.nsh"
!include "vidalia_es.nsh"
!include "vidalia_fa.nsh"
!include "vidalia_fi.nsh"
!include "vidalia_fr.nsh"
!include "vidalia_nl.nsh"
!include "vidalia_pl.nsh"
!include "vidalia_pt-br.nsh"
!include "vidalia_ru.nsh"
!include "vidalia_zh-cn.nsh"
!include "vidalia_zh-tw.nsh"

;--------------------------------
; Install types
!ifndef NOINSTTYPES ; only if not defined
  InstType "Full"
  InstType "Base"
  ;InstType /COMPONENTSONLYONCUSTOM
!endif



;--------------------------------
; Tor
Var configdir
Var configfile
var bInstallTor
SectionGroup "!${TOR_DESC}" TorGroup
    ;--------------------------------
    ; Tor application binaries
    Section "${TOR_NAME}" Tor
    ;Files that have to be installed for tor to run and that the user
    ;cannot choose not to install
       SectionIn 1 2
       SetOutPath "$INSTDIR\Tor"
       File "tor\${TOR_APPVERSION}\tor.exe"
       File "tor\${TOR_APPVERSION}\tor-resolve.exe"
       WriteIniStr "$INSTDIR\Tor\Tor Website.url" "InternetShortcut" "URL" "http://tor.eff.org"

       StrCpy $configfile "torrc"
       StrCpy $configdir $APPDATA\Tor
       SetOutPath $configdir

       ;If there's already a torrc config file, ask if they want to
       ;overwrite it with the new one.
       IfFileExists "$configdir\torrc" "" endiftorrc
         MessageBox MB_ICONQUESTION|MB_YESNO "$(TorAskOverwriteTorrc)" IDNO noreplace
         Delete $configdir\torrc
         Goto endiftorrc
       noreplace:
         StrCpy $configfile "torrc.sample"
       endiftorrc:
         File /oname=$configfile "tor\${TOR_APPVERSION}\torrc.sample"
       
        ; Write the uninstall keys for Windows
        WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Tor" "DisplayName" "${TOR_DESC}"
        WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Tor" "UninstallString" '"$INSTDIR\${UNINSTALLER}"'
        WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Tor" "NoModify" 1
        WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Tor" "NoRepair" 1
       
       IntOp $bInstallTor 0 + 1
    SectionEnd

    ;--------------------------------
    ; OpenSSL binaries
    Section "$(TorOpenSSL)" TorOpenSSL
       SectionIn 1 2
       SetOutPath "$INSTDIR\Tor"
       File "tor\${TOR_APPVERSION}\libcrypto.a"
       File "tor\${TOR_APPVERSION}\libssl.a"
    SectionEnd

    ;--------------------------------
    ; Tor documentation
    Section "$(TorDocumentation)" TorDocs
       SectionIn 1
       SetOutPath "$INSTDIR\Tor\Documents"
       File "tor\${TOR_APPVERSION}\Documents\*.*"
    SectionEnd

    ;--------------------------------
    ; Tor Start menu shortcuts
    Section "$(TorShortcuts)" TorShortcuts
      SectionIn 1
        SetShellVarContext all ; (Add to "All Users" Start Menu if possible)
        SetOutPath "$INSTDIR\Tor"
        IfFileExists "${SHORTCUTS}\Tor\*.*" "" +2
           RMDir /r "${SHORTCUTS}\Tor"
        
        CreateDirectory "${SHORTCUTS}\Tor"
        CreateShortCut  "${SHORTCUTS}\Tor\Tor.lnk" "$INSTDIR\Tor\tor.exe"
        CreateShortCut  "${SHORTCUTS}\Tor\Torrc.lnk" "Notepad.exe" "$configdir\torrc"
        CreateShortCut  "${SHORTCUTS}\Tor\Tor Website.lnk" "$INSTDIR\Tor\Tor Website.url"
        CreateShortCut "${SHORTCUTS}\Uninstall.lnk" "$INSTDIR\Uninstall.exe" "" "$INSTDIR\${UNINSTALLER}" 0
        
        IfFileExists "$INSTDIR\Tor\Documents\*.*" "" endifdocs
          CreateDirectory "${SHORTCUTS}\Tor\Documents"
          CreateShortCut  "${SHORTCUTS}\Tor\Documents\Tor Manual.lnk" "$INSTDIR\Tor\Documents\tor-reference.html"
          CreateShortCut  "${SHORTCUTS}\Tor\Documents\Tor Documentation.lnk" "$INSTDIR\Tor\Documents"
          CreateShortCut  "${SHORTCUTS}\Tor\Documents\Tor Specification.lnk" "$INSTDIR\Tor\Documents\tor-spec.txt"
        endifdocs:
    SectionEnd
SectionGroupEnd


;--------------------------------
; Vidalia
var bInstallVidalia
SectionGroup "${VIDALIA_DESC}" VidaliaGroup
    ;--------------------------------
    ; Vidalia application binaries
    Section "${VIDALIA_NAME}" Vidalia
      SectionIn 1 2

      ; Set output path to the installation directory.
      SetOutPath "$INSTDIR\Vidalia"
      File "Vidalia\${VIDALIA_APPVERSION}\${VIDALIA_EXEC}"
      File "Vidalia\${VIDALIA_APPVERSION}\mingwm10.dll"
      File "Vidalia\${VIDALIA_APPVERSION}\README"
      File "Vidalia\${VIDALIA_APPVERSION}\CHANGELOG"
      File "Vidalia\${VIDALIA_APPVERSION}\LICENSE"
      File "Vidalia\${VIDALIA_APPVERSION}\COPYING"
      File "Vidalia\${VIDALIA_APPVERSION}\AUTHORS"

      
      ; Include a prebuilt GeoIP cache
      SetShellVarContext current
      CreateDirectory "$APPDATA\Vidalia"
      SetOutPath "$APPDATA\Vidalia"
      File "Vidalia\${VIDALIA_APPVERSION}\geoip-cache"

      ; Tor gets installed to $INSTDIR\Tor, so let's remember it
      ; But first, we have to replace all the '\'s with '\\'s in the $INSTDIR
      ; Does NSIS make this easy by providing the ability to replace substrings? No.
      Push $INSTDIR
      Push "\"
      Push "\\"
      Call StrRep
      Pop $R0 ; contains the modified version of $INSTDIR
      WriteINIStr "$APPDATA\Vidalia\vidalia.conf" Tor TorExecutable "$R0\\Tor\\${TOR_EXEC}"

      ; Write the uninstall keys for Windows  
      SetShellVarContext all
      WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Vidalia" "DisplayName" "${VIDALIA_DESC}"
      WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Vidalia" "UninstallString" '"$INSTDIR\${UNINSTALLER}"'
      WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Vidalia" "NoModify" 1
      WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Vidalia" "NoRepair" 1
     
      IntOp $bInstallVidalia 0 + 1
    SectionEnd

    ;--------------------------------
    ; Vidalia Start menu shortcuts
    Section "$(VidaliaShortcuts)" VidaliaShortcuts
      SectionIn 1
      SetShellVarContext all ; (Add to "All Users" Start Menu if possible)
      CreateShortCut "${SHORTCUTS}\Uninstall.lnk" "$INSTDIR\Uninstall.exe" "" "$INSTDIR\${UNINSTALLER}" 0
      CreateShortCut "${SHORTCUTS}\Vidalia.lnk" "$INSTDIR\Vidalia\${VIDALIA_EXEC}" "" "$INSTDIR\Vidalia\${VIDALIA_EXEC}" 0
      
      WriteIniStr "$INSTDIR\Vidalia\Vidalia Website.url" "InternetShortcut" "URL" "http://www.vidalia-project.net"
      CreateShortCut "${SHORTCUTS}\Vidalia Website.lnk" "$INSTDIR\Vidalia\Vidalia Website.url"
    SectionEnd

    ;--------------------------------
    ; Run Vidalia at startup
    Section "$(VidaliaStartup)" VidaliaStartup
      SectionIn 1
      WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "${VIDALIA_NAME}" '"$INSTDIR\Vidalia\${VIDALIA_EXEC}"'
    SectionEnd    
SectionGroupEnd


;--------------------------------
; Privoxy
var bInstallPrivoxy
SectionGroup "${PRIVOXY_DESC}" PrivoxyGroup
    ;--------------------------------
    ; Privoxy application binaries
    Section "${PRIVOXY_NAME}" Privoxy
        SectionIn 1 2
        ; add files / whatever that need to be installed here.
        SetOutPath "$INSTDIR\Privoxy"
        File /r Privoxy\${PRIVOXY_APPVERSION}\*.*

        WriteRegStr HKEY_CLASSES_ROOT "PrivoxyActionFile\shell\open\command" "" 'Notepad.exe "%1"'
        WriteRegStr HKEY_CLASSES_ROOT ".action" "" "PrivoxyActionFile"
        WriteRegStr HKEY_CLASSES_ROOT "PrivoxyFilterFile\shell\open\command" "" 'Notepad.exe "%1"'
        WriteRegStr HKEY_CLASSES_ROOT ".filter" "" "PrivoxyFilterFile"
       
        ; Write the installation path into the registry
        WriteRegStr HKCU SOFTWARE\Privoxy "Install_Dir" "$INSTDIR"

        ; Write the uninstall keys for Windows
        WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Privoxy" "DisplayName" "${PRIVOXY_DESC}"
        WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Privoxy" "UninstallString" '"$INSTDIR\${UNINSTALLER}"'
        WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Privoxy" "NoModify" 1
        WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Privoxy" "NoRepair" 1
       
        IntOp $bInstallPrivoxy 0 + 1
    SectionEnd

    ;--------------------------------
    ; Privoxy Start menu shortcuts
    Section "$(PrivoxyShortcuts)" PrivoxyShortcuts
        SectionIn 1
        SetShellVarContext all ; (Add to "All Users" Start Menu if possible)
        RMDir /r "${SHORTCUTS}\Privoxy"
        CreateDirectory "${SHORTCUTS}\Privoxy"
        CreateShortCut "${SHORTCUTS}\Privoxy\Privoxy.lnk" "$INSTDIR\Privoxy\privoxy.exe"
        CreateShortCut "${SHORTCUTS}\Privoxy\Web-based Feedback.lnk" "$INSTDIR\Privoxy\doc\user-manual\contact.html"
        WriteINIStr "${SHORTCUTS}\Privoxy\Web-based Configuration.url" "InternetShortcut" "URL" "http://config.privoxy.org/"
        
        CreateDirectory "${SHORTCUTS}\Privoxy\Edit Config"
        CreateShortCut "${SHORTCUTS}\Privoxy\Edit Config\Main Configuration.lnk" "Notepad.exe" '"$INSTDIR\Privoxy\config.txt"'
        CreateShortCut "${SHORTCUTS}\Privoxy\Edit Config\Default Actions.lnk" "Notepad.exe" '"$INSTDIR\Privoxy\default.action"'
        CreateShortCut "${SHORTCUTS}\Privoxy\Edit Config\User Actions.lnk" "Notepad.exe" '"$INSTDIR\Privoxy\user.action"'
        CreateShortCut "${SHORTCUTS}\Privoxy\Edit Config\Filters.lnk" "Notepad.exe" '"$INSTDIR\Privoxy\default.filter"'
        CreateShortCut "${SHORTCUTS}\Privoxy\Edit Config\Trust list.lnk" "Notepad.exe" '"$INSTDIR\Privoxy\trust.txt"'
        
        CreateDirectory "${SHORTCUTS}\Privoxy\Documentation"
        CreateShortCut "${SHORTCUTS}\Privoxy\Documentation\User Manual.lnk" "$INSTDIR\Privoxy\doc\user-manual\index.html"
        CreateShortCut "${SHORTCUTS}\Privoxy\Documentation\Frequently Asked Questions.lnk" "$INSTDIR\Privoxy\doc\faq\index.html"
        CreateShortCut "${SHORTCUTS}\Privoxy\Documentation\Credits.lnk" "Notepad.exe" '"$INSTDIR\Privoxy\AUTHORS.txt"'
        CreateShortCut "${SHORTCUTS}\Privoxy\Documentation\License.lnk" "Notepad.exe" '"$INSTDIR\Privoxy\LICENSE.txt"'
        CreateShortCut "${SHORTCUTS}\Privoxy\Documentation\ReadMe file.lnk" "Notepad.exe" '"$INSTDIR\Privoxy\README.txt"'
        WriteINIStr "$SMPROGRAMS\Privoxy\Documentation\Web Site.url" "InternetShortcut" "URL" "http://privoxy.org/"
        
        CreateShortCut "${SHORTCUTS}\Uninstall.lnk" "$INSTDIR\Uninstall.exe" "" "$INSTDIR\${UNINSTALLER}" 0
    SectionEnd
 
    ;--------------------------------
    ; Run Privoxy at startup
    Section "$(PrivoxyStartup)" PrivoxyStartup
      SectionIn 1
      CreateShortCut "$SMSTARTUP\Privoxy.lnk" "$INSTDIR\Privoxy\privoxy.exe" "" "" 0 SW_SHOWMINIMIZED
    SectionEnd     
SectionGroupEnd

;--------------------------------
; Torbutton
SectionGroup "${TORBUTTON_DESC}" TorbuttonGroup
  Section "${TORBUTTON_NAME}" Torbutton
    SectionIn 1 2
    SetOutPath "$INSTDIR\Torbutton"
    File torbutton\${TORBUTTON_APPVERSION}\torbutton-${TORBUTTON_APPVERSION}.xpi
  SectionEnd

  Section "$(TorbuttonAddToFirefox)" TorbuttonAddToFirefox
    SectionIn 1 2
    ReadRegStr $1 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\firefox.exe" "Path"
    StrCmp $1 "" FirefoxNotFound 0 ; if Path is empty or null, then skip to an error, otherwise proceed
	  Exec '"$1firefox.exe" -install-global-extension "$INSTDIR\Torbutton\torbutton-${TORBUTTON_APPVERSION}.xpi"'
  	Goto TorbuttonInstalled
    FirefoxNotFound:
	  MessageBox MB_OK|MB_ICONSTOP "$(TorbuttonFirefoxNotFound)"
    TorbuttonInstalled:
  SectionEnd
SectionGroupEnd

Section "" end
  SetOutPath "$INSTDIR"
  File "BUNDLE_LICENSE"
  
  WriteUninstaller "$INSTDIR\${UNINSTALLER}"
SectionEnd

;--------------------------------
; Functions
Function .onInit
  !insertmacro MUI_LANGDLL_DISPLAY
FunctionEnd

Function .onSelChange
  Push $0

  ; Check if the Torbutton option was unchecked
  SectionGetFlags ${Torbutton} $0
  IntOp $0 $0 & ${SF_SELECTED}
  IntCmp $0 0 0 SelChangeDone SelChangeDone

  ; Uncheck the "Add to Firefox" box
  SectionGetFlags ${TorbuttonAddToFirefox} $0
  IntOp $0 $0 & ${SECTION_OFF}
  SectionSetFlags ${TorbuttonAddToFirefox} $0
  
  SelChangeDone:
  Pop $0
FunctionEnd

Function CustomFinishFn
    IntCmp $bInstallVidalia 1 run_vidalia check_tor check_tor
    run_vidalia:
        Exec '"$INSTDIR\Vidalia\${VIDALIA_EXEC}"'
        goto check_privoxy
    
    check_tor:
    IntCmp $bInstallTor 1 run_tor check_privoxy check_privoxy
    run_tor:
        Exec '"$INSTDIR\Tor\${TOR_EXEC}"'
    
    check_privoxy:
    IntCmp $bInstallPrivoxy 1 run_privoxy done done
    run_privoxy:
        SetOutPath "$INSTDIR\Privoxy"
        ExecShell "" '"$INSTDIR\Privoxy\${PRIVOXY_EXEC}"' "" SW_SHOWMINIMIZED
    done:
FunctionEnd

;-------------------------
; Uninstaller
Section "-Uninstall" Uninstall
SectionEnd
   
Section "un.Tor ${TOR_APPVERSION}" UninstallTor
  SetShellVarContext current
  RMDir /r "$APPDATA\Tor"
  SetShellVarContext all
  RMDir /r "$INSTDIR\Tor"
  RMDir /r "$APPDATA\Tor"
  RMDir /r "${SHORTCUTS}\Tor"
  DeleteRegKey HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Tor"
SectionEnd

Section "un.Vidalia ${VIDALIA_APPVERSION}" UninstallVidalia
  SetShellVarContext current
  RMDir /r "$APPDATA\Vidalia"
  SetShellVarContext all
  RMDir /r "$INSTDIR\Vidalia"
  RMDir /r "$APPDATA\Vidalia"
  Delete "${SHORTCUTS}\Vidalia.lnk"
  Delete "${SHORTCUTS}\Vidalia Website.lnk"
  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Run\Vidalia"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Vidalia"
SectionEnd

Section "un.Privoxy ${PRIVOXY_APPVERSION}" UninstallPrivoxy
  SetShellVarContext all
  RMDir /r "$INSTDIR\Privoxy"
  RMDir /r "${SHORTCUTS}\Privoxy"
  Delete "$SMSTARTUP\Privoxy.lnk"
  DeleteRegKey HKEY_CLASSES_ROOT ".action"
  DeleteRegKey HKEY_CLASSES_ROOT "PrivoxyActionFile"
  DeleteRegKey HKEY_CLASSES_ROOT ".filter"
  DeleteRegKey HKEY_CLASSES_ROOT "PrivoxyFilterFile"
  DeleteRegKey HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Privoxy"
SectionEnd

; XXX: We still need to find a way to actually remove Torbutton from Firefox
;Section "un.Torbutton ${TORBUTTON_APPVERSION}" UninstallTorbutton
;  RMDir /r "$INSTDIR\Torbutton"
;  DeleteRegKey HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Tor"
;SectionEnd

Function un.onInit
  !insertmacro MUI_LANGDLL_DISPLAY

  IfFileExists "$INSTDIR\Tor\*.*" CheckVidalia
    SectionGetFlags ${UninstallTor} $0
    IntOp $0 $0 & ${SECTION_OFF}
    SectionSetFlags ${UninstallTor} $0

  CheckVidalia:
  IfFileExists "$INSTDIR\Vidalia\*.*" CheckPrivoxy
    SectionGetFlags ${UninstallVidalia} $0
    IntOp $0 $0 & ${SECTION_OFF}
    SectionSetFlags ${UninstallVidalia} $0

  CheckPrivoxy:
  IfFileExists "$INSTDIR\Privoxy\*.*" Done
    SectionGetFlags ${UninstallPrivoxy} $0
    IntOp $0 $0 & ${SECTION_OFF}
    SectionSetFlags ${UninstallPrivoxy} $0

  Done:
FunctionEnd

Function un.onUninstSuccess
  SetShellVarContext all
  IfFileExists "$INSTDIR\Tor\*.*" DontRemoveTheUninstaller
  IfFileExists "$INSTDIR\Vidalia\*.*" DontRemoveTheUninstaller
  IfFileExists "$INSTDIR\Privoxy\*.*" DontRemoveTheUninstaller
  RMDir /r "$INSTDIR"
  RMDir /r "${SHORTCUTS}"
  DontRemoveTheUninstaller:
FunctionEnd

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${Tor} "$(TorAppDesc)"
  !insertmacro MUI_DESCRIPTION_TEXT ${TorGroup} "$(TorGroupDesc)"
  !insertmacro MUI_DESCRIPTION_TEXT ${TorOpenSSL} "$(TorOpenSSLDesc)"
  !insertmacro MUI_DESCRIPTION_TEXT ${TorDocs} "$(TorDocumentationDesc)"
  !insertmacro MUI_DESCRIPTION_TEXT ${TorShortcuts} "$(TorShortcutsDesc)"

  !insertmacro MUI_DESCRIPTION_TEXT ${Vidalia} "$(VidaliaAppDesc)"
  !insertmacro MUI_DESCRIPTION_TEXT ${VidaliaGroup} "$(VidaliaGroupDesc)"
  !insertmacro MUI_DESCRIPTION_TEXT ${VidaliaStartup} "$(VidaliaStartupDesc)"
  !insertmacro MUI_DESCRIPTION_TEXT ${VidaliaShortcuts} "$(VidaliaShortcutsDesc)"

  !insertmacro MUI_DESCRIPTION_TEXT ${Privoxy} "$(PrivoxyAppDesc)"
  !insertmacro MUI_DESCRIPTION_TEXT ${PrivoxyGroup} "$(PrivoxyGroupDesc)"
  !insertmacro MUI_DESCRIPTION_TEXT ${PrivoxyStartup} "$(PrivoxyStartupDesc)"
  !insertmacro MUI_DESCRIPTION_TEXT ${PrivoxyShortcuts} "$(PrivoxyShortcutsDesc)"

  !insertmacro MUI_DESCRIPTION_TEXT ${Torbutton} "$(TorbuttonAppDesc)"
  !insertmacro MUI_DESCRIPTION_TEXT ${TorbuttonGroup} "$(TorbuttonGroupDesc)"
  !insertmacro MUI_DESCRIPTION_TEXT ${TorbuttonAddToFirefox} "$(TorbuttonAddToFirefoxDesc)"
!insertmacro MUI_FUNCTION_DESCRIPTION_END

!insertmacro MUI_UNFUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${UninstallTor} "$(TorUninstDesc)"
  !insertmacro MUI_DESCRIPTION_TEXT ${UninstallVidalia} "$(VidaliaUninstDesc)"
  !insertmacro MUI_DESCRIPTION_TEXT ${UninstallPrivoxy} "$(PrivoxyUninstDesc)"
!insertmacro MUI_UNFUNCTION_DESCRIPTION_END


Function StrRep
 
  ;Written by dirtydingus 2003-02-20 04:30:09 
  ; USAGE
  ;Push String to do replacement in (haystack)
  ;Push String to replace (needle)
  ;Push Replacement
  ;Call StrRep
  ;Pop $R0 result	
 
  Exch $R4 ; $R4 = Replacement String
  Exch
  Exch $R3 ; $R3 = String to replace (needle)
  Exch 2
  Exch $R1 ; $R1 = String to do replacement in (haystack)
  Push $R2 ; Replaced haystack
  Push $R5 ; Len (needle)
  Push $R6 ; len (haystack)
  Push $R7 ; Scratch reg
  StrCpy $R2 ""
  StrLen $R5 $R3
  StrLen $R6 $R1
loop:
  StrCpy $R7 $R1 $R5
  StrCmp $R7 $R3 found
  StrCpy $R7 $R1 1 ; - optimization can be removed if U know len needle=1
  StrCpy $R2 "$R2$R7"
  StrCpy $R1 $R1 $R6 1
  StrCmp $R1 "" done loop
found:
  StrCpy $R2 "$R2$R4"
  StrCpy $R1 $R1 $R6 $R5
  StrCmp $R1 "" done loop
done:
  StrCpy $R3 $R2
  Pop $R7
  Pop $R6
  Pop $R5
  Pop $R2
  Pop $R1
  Pop $R4
  Exch $R3
	
FunctionEnd

