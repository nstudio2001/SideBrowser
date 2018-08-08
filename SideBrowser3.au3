#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=chrome_logo_gnw_icon.ico
#AutoIt3Wrapper_Res_Fileversion=3.0.0.0
#AutoIt3Wrapper_Res_LegalCopyright=NorthStudio
#AutoIt3Wrapper_Res_File_Add=arrowCI.otf
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <GUIConstantsEx.au3>
#include <ButtonConstants.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <StaticConstants.au3>
#include <Array.au3>
#include <GUIListView.au3>
#include <GDIPlus.au3>
#include <WinAPIGdi.au3>
#include <WinAPISysWin.au3>
#include <WinAPIRes.au3>
#include <Misc.au3>
#include <Inet.au3>
#include <Cefau3_udf/Cefau3.au3>
#include "v3UDF/GUICtrlOnHover.au3"
#include "v3UDF/onEventFunc.au3"

Global $oError = ObjEvent("AutoIt.Error", "_ErrFunc")
Func _ErrFunc()
;~  ConsoleWrite($oError.scriptline & ";" & $oError.source & ";" & $oError.description & @CRLF)
    Return 0
EndFunc

Opt("GUIOnEventMode", 1)
Opt("MustDeclareVars", 1)

If Not FileExists(@TempDir & "\arrowCI.otf") Then
	FileInstall("arrowCI.otf", @TempDir & "\arrowCI.otf")
EndIf
Global $hFont = _WinAPI_AddFontResourceEx(@TempDir & "\arrowCI.otf")

;=============== CONFIG COLORS
Global $menuBackgroundColor = StorageRead("BackgroundColor") = "" ? 0x000000 : StorageRead("BackgroundColor") ; Background color		(Default is black)
Global $menuTextColor = StorageRead("TextColor") = "" ? 0xFFFFFF : StorageRead("TextColor") ; Text color			(Default is white)
Global $menuHoverTextColor = StorageRead("HoverTextColor") = "" ? 0xFFFFFF : StorageRead("HoverTextColor") ; Text color when hover	(Default is white)
Global $menuBtnColor = StorageRead("BtnColor") = "" ? 0x000000 : StorageRead("BtnColor") ; Button color			(Default is black)
Global $menuBtnColorHover = StorageRead("BtnColorHover") = "" ? 0x191919 : StorageRead("BtnColorHover") ; Button color			(Default is black)
Global $closeButtonColor = StorageRead("CloseBtnColor") = "" ? 0xc0392b : StorageRead("CloseBtnColor") ; Close Button color	(Lighter-Red by default)
Global $closeButtonColorHover = StorageRead("CloseBtnColorHover") = "" ? 0xe74c3c : StorageRead("CloseBtnColorHover") ; Close Button color	(Red by default)
Global $menuMode = "" ; normal Mode

Global $GUIDisplay = False
Global $GUIResizing = False
Global $GUICursor = 0

Const $DesktopWidth = @DesktopWidth
Const $DesktopHeight = @DesktopHeight
Const $ButtonSize = 48
Const $taskbarSize = WinGetPos("[CLASS:Shell_TrayWnd;INSTANCE:1]", "")[3]
Const $taskBarY = WinGetPos("[CLASS:Shell_TrayWnd;INSTANCE:1]", "")[1]
If StorageRead('CoverTaskbar') = 1 Then
	Global $GUIHeight = $DesktopHeight
Else
	Global $GUIHeight = $DesktopHeight - $taskbarSize
EndIf
If $taskBarY = 0 Then
	Local $GuiStartY = $taskbarSize
Else
	Local $GuiStartY = 0
EndIf

Global $BrowserSize = StorageRead("BrowserSize") = "" ? 500 : StorageRead("BrowserSize")

Global $oldMouseX = 0
Global $newBrowserSize = $BrowserSize

Global $hGUI = GUICreate("SideBrowser", $BrowserSize + $ButtonSize + 8, $GUIHeight, $DesktopWidth - $BrowserSize - $ButtonSize - 8, $GuiStartY, BitOR($WS_POPUP, $WS_CLIPCHILDREN, $WS_CLIPSIBLINGS))
GUISetBkColor(0x191919)


Global $closeButton = GUICtrlCreateLabel(ChrW(Dec('e870')), 8, 0, $ButtonSize, $ButtonSize, BitOR($SS_CENTER, $SS_CENTERIMAGE))
_GUICtrl_OnHoverRegister(-1, "_CloseBtnHover", "_CloseBtnHover", "_Exit")
GUICtrlSetOnEvent(-1, '_Handle_menu')
GUICtrlSetBkColor(-1, 0xe51400)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetFont(-1, 16, 0, 0, "arrowCI")
GUICtrlSetResizing(-1, 2 + 32 + 256 + 512)

Global $pinned = False

Global $BrowserTabs[20][20]
Global $maxAllowTab = 2
Global $TabCount = 0
Global $CurTab = 0

Global $btn_back = GUICtrlCreateLabel(ChrW(Dec("e875")), 8 + $ButtonSize + 8, $ButtonSize + 8, 32, 32, BitOR($SS_CENTER, $SS_CENTERIMAGE))
_GUICtrl_OnHoverRegister(-1, "_Nav_Hover", "_Nav_Hover")
GUICtrlSetOnEvent(-1, "_Handle_Menu")
GUICtrlSetBkColor(-1, 0x191919)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetFont(-1, 12, 0, 0, 'arrowCI', 5)
GUICtrlSetResizing(-1, 2 + 32 + 256 + 512)

Global $btn_next = GUICtrlCreateLabel(ChrW(Dec("e876")), 8 + $ButtonSize + 42, $ButtonSize + 8, 32, 32, BitOR($SS_CENTER, $SS_CENTERIMAGE))
_GUICtrl_OnHoverRegister(-1, "_Nav_Hover", "_Nav_Hover")
GUICtrlSetOnEvent(-1, "_Handle_Menu")
GUICtrlSetBkColor(-1, 0x191919)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetFont(-1, 12, 0, 0, 'arrowCI', 5)
GUICtrlSetResizing(-1, 2 + 32 + 256 + 512)

Global $btn_reload = GUICtrlCreateLabel(ChrW(Dec("e862")), 8 + $ButtonSize + 80, $ButtonSize + 8, 32, 32, BitOR($SS_CENTER, $SS_CENTERIMAGE))
_GUICtrl_OnHoverRegister(-1, "_Nav_Hover", "_Nav_Hover")
GUICtrlSetOnEvent(-1, "_Handle_Menu")
GUICtrlSetBkColor(-1, 0x191919)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetFont(-1, 12, 0, 0, 'arrowCI', 5)
GUICtrlSetResizing(-1, 2 + 32 + 256 + 512)

Global $btn_closetab = GUICtrlCreateLabel(ChrW(Dec("e880")), 8 + $ButtonSize + 116, $ButtonSize + 8, 32, 32, BitOR($SS_CENTER, $SS_CENTERIMAGE))
_GUICtrl_OnHoverRegister(-1, "_Nav_Hover", "_Nav_Hover")
GUICtrlSetOnEvent(-1, "_Handle_Menu")
GUICtrlSetBkColor(-1, 0x191919)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetFont(-1, 12, 0, 0, 'arrowCI', 5)
GUICtrlSetResizing(-1, 2 + 32 + 256 + 512)

Global $inp_url = GUICtrlCreateInput("https://google.com", 8 + $ButtonSize + 156, $ButtonSize + 10, $BrowserSize - 172, 28)
GUICtrlSetFont(-1, 12, 0, 0, 'Segoe UI Light')
GUICtrlSetResizing(-1, 2 + 4)

Global $cDummy = GUICtrlCreateDummy()
Dim $AccelKeys[1][2] = [["{ENTER}", $cDummy]]
GUISetAccelerators($AccelKeys)
GUICtrlSetOnEvent($cDummy, "_Handle_Menu")


Global $btn_newtab = GUICtrlCreateLabel('+', 8, $ButtonSize, $ButtonSize, $ButtonSize, BitOR($SS_CENTER, $SS_CENTERIMAGE))
_GUICtrl_OnHoverRegister(-1, "_Menu_Hover", "_Menu_Hover")
GUICtrlSetOnEvent(-1, "_Handle_Menu")
GUICtrlSetBkColor(-1, 0x191919)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetFont(-1, 16, 0, 0, 'arrowCI', 5)
GUICtrlSetResizing(-1, 2 + 32 + 256 + 512)

Global $btn_pin = GUICtrlCreateLabel(ChrW(Dec('e832')), 8, $ButtonSize * 2, $ButtonSize, $ButtonSize, BitOR($SS_CENTER, $SS_CENTERIMAGE))
_GUICtrl_OnHoverRegister(-1, "_Menu_Hover", "_Menu_Hover")
GUICtrlSetOnEvent(-1, "_Handle_Menu")
GUICtrlSetBkColor(-1, 0x191919)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetFont(-1, 16, 0, 0, 'arrowCI', 5)
GUICtrlSetResizing(-1, 2 + 32 + 256 + 512)

Global $btn_facebook = GUICtrlCreateLabel(ChrW(Dec('00ad')), 8, $ButtonSize * 3, $ButtonSize, $ButtonSize, BitOR($SS_CENTER, $SS_CENTERIMAGE))
_GUICtrl_OnHoverRegister(-1, "_Menu_Hover", "_Menu_Hover")
GUICtrlSetOnEvent(-1, "_Handle_Menu")
GUICtrlSetBkColor(-1, 0x191919)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetFont(-1, 16, 0, 0, 'arrowCI', 5)
GUICtrlSetResizing(-1, 2 + 32 + 256 + 512)

Global $btn_gmail = GUICtrlCreateLabel(ChrW(Dec('00af')), 8, $ButtonSize * 4, $ButtonSize, $ButtonSize, BitOR($SS_CENTER, $SS_CENTERIMAGE))
_GUICtrl_OnHoverRegister(-1, "_Menu_Hover", "_Menu_Hover")
GUICtrlSetOnEvent(-1, "_Handle_Menu")
GUICtrlSetBkColor(-1, 0x191919)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetFont(-1, 16, 0, 0, 'arrowCI', 5)
GUICtrlSetResizing(-1, 2 + 32 + 256 + 512)

Global $btn_messenger = GUICtrlCreateLabel(ChrW(Dec('00c1')), 8, $ButtonSize * 5, $ButtonSize, $ButtonSize, BitOR($SS_CENTER, $SS_CENTERIMAGE))
_GUICtrl_OnHoverRegister(-1, "_Menu_Hover", "_Menu_Hover")
GUICtrlSetOnEvent(-1, "_Handle_Menu")
GUICtrlSetBkColor(-1, 0x191919)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetFont(-1, 16, 0, 0, 'arrowCI', 5)
GUICtrlSetResizing(-1, 2 + 32 + 256 + 512)

Global $btn_settings = GUICtrlCreateLabel(ChrW(Dec('e810')), 8, $ButtonSize * 6, $ButtonSize, $ButtonSize, BitOR($SS_CENTER, $SS_CENTERIMAGE))
_GUICtrl_OnHoverRegister(-1, "_Menu_Hover", "_Menu_Hover")
GUICtrlSetOnEvent(-1, "_Handle_Menu")
GUICtrlSetBkColor(-1, 0x191919)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetFont(-1, 16, 0, 0, 'arrowCI', 5)
GUICtrlSetResizing(-1, 2 + 32 + 256 + 512)

Global $justPadding = GUICtrlCreateLabel("", 0, 0, 8, $GUIHeight)
GUICtrlSetBkColor(-1, 0x101010)
GUICtrlSetResizing(-1, 2 + 32 + 256 + 512)

Cef_Start()
Cef_EnableHighDPI()

Global $BrowserLoading = True
Global $BrowserSetURL = False
Func _OnLoadStart($Cef, $CefBrowser, $CefDragData, $CefFrame, $iTransitionType)
	For $i = 1 To $TabCount
		If $BrowserTabs[$i][1] = $Cef Then
			$BrowserTabs[$i][8] = ''
			$BrowserTabs[$i][5] = False
		EndIf
	Next
EndFunc   ;==>_OnLoadStart

Func _OnLoadEnd($Cef, $CefBrowser, $CefDragData, $CefFrame, $iHttpStatusCode)
	For $i = 1 To $TabCount
		If $BrowserTabs[$i][1] = $Cef Then
			$BrowserTabs[$i][5] = True
			$BrowserTabs[$i][13] = False
		EndIf
	Next
EndFunc   ;==>_OnLoadEnd

Func _OnAddressChange($Cef, $CefBrowser, $CefFrame, $sURL)
;~ 	Cef_ExecuteJs($Cef_Toolbar, 'document.getElementById("urlInput").value = "'&$sURL&'";')
;~ 	Cef_ExecuteJs($Cef_Toolbar, 'document.getElementById("favicon").src = "https://www.google.com/s2/favicons?domain='&$sURL&'";')
	For $i = 1 To $TabCount
		If $BrowserTabs[$i][1] = $Cef Then
			$BrowserTabs[$i][7] = $sURL
		EndIf
	Next
;~ 	if $BrowserTabs[$CurTab][1] = $Cef Then
;~ 		GUICtrlSetData($inp_url, $sURL)
;~ 	EndIf
EndFunc   ;==>_OnAddressChange

Func _OnTitleChange($Cef, $CefBrowser, $sTitle)
	For $i = 1 To $TabCount
		If $BrowserTabs[$i][1] = $Cef Then
			If $BrowserTabs[$i][8] = '' Then
				$BrowserTabs[$i][8] = $sTitle
			EndIf
		EndIf
	Next
EndFunc   ;==>_OnTitleChange

_CreateTab()

Func _UpdateTabTitle($iTab, $sTitle)
	GUICtrlSetData($BrowserTabs[$iTab][2], $sTitle)
EndFunc   ;==>_UpdateTabTitle

Global $start_with_win_cb, $lb_author, $cover_taskbar_cb

GUISetState(@SW_HIDE)
While 1
	For $i = 1 To $TabCount
		If $BrowserTabs[$i][4] <> 'destroyed' Then
			If $BrowserTabs[$i][5] = True Then
				If $BrowserTabs[$i][13] = False Then
					_UpdateTabTitle($i, $BrowserTabs[$i][8])
					If $i = $CurTab Then
						GUICtrlSetData($inp_url, $BrowserTabs[$i][7])
					EndIf
					$BrowserTabs[$i][13] = True
				EndIf
			EndIf
		EndIf
	Next
	Local $mousePos = MouseGetPos()
	Local $mouseX = $mousePos[0]
	If $GUIDisplay = False Then
		If $mouseX >= $DesktopWidth - 2 Then
			GUISetState(@SW_SHOW)
			$GUIDisplay = True
		EndIf
	Else
		If $GUIResizing Then
			If _IsPressed(01) Then
				If $DesktopWidth - $mouseX >= 500 Then
					$newBrowserSize = $BrowserSize + $oldMouseX - $mouseX
				EndIf
				WinMove("", "", $DesktopWidth - $newBrowserSize - $ButtonSize - 8, 0, $newBrowserSize + $ButtonSize + 8, $GUIHeight)
				_WinAPI_MoveWindow(Cef_GetHandle($BrowserTabs[$CurTab][1]), $ButtonSize + 8, $ButtonSize * 2, $newBrowserSize, $GUIHeight)
			Else
				$BrowserSize = $newBrowserSize
				StorageWrite("BrowserSize", $BrowserSize)
				$GUIResizing = False
			EndIf
		ElseIf MouseGetPos()[0] <= $DesktopWidth - $BrowserSize - $ButtonSize - 8 And Not $pinned Then
			GUISetState(@SW_HIDE)
			$GUIDisplay = False
		Else
			If $mouseX >= $DesktopWidth - $BrowserSize - $ButtonSize - 8 And $mouseX <= $DesktopWidth - $BrowserSize - $ButtonSize Then
				If $GUICursor <> 13 Then
					GUISetCursor(13, 1)
					$GUICursor = 13
				EndIf
				If _IsPressed(01) Then
					$GUIResizing = True
					$oldMouseX = $mouseX
				EndIf
			ElseIf $GUICursor <> 2 Then
				GUISetCursor(2, 1)
				$GUICursor = 2
			EndIf
		EndIf
	EndIf
	Sleep(100)
WEnd


Func _Event_Settings()
	Switch @GUI_CtrlId
		Case $start_with_win_cb
			If GUICtrlRead($start_with_win_cb) = $GUI_CHECKED Then
				RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run", "altersidebar", "REG_SZ", @ScriptFullPath)
			Else
				RegDelete("HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run", "altersidebar")
			EndIf
		Case $cover_taskbar_cb
			If GUICtrlRead($cover_taskbar_cb) = $GUI_CHECKED Then
				StorageWrite('CoverTaskbar', 1)
			Else
				StorageWrite('CoverTaskbar', 0)
			EndIf
		Case $lb_author
			ShellExecute("https://facebook.com/MonokaiJs")
	EndSwitch
EndFunc   ;==>_Event_Settings

Func _Handle_Menu()
	Switch @GUI_CtrlId
		Case $cDummy
			If _WinAPI_GetFocus() = GUICtrlGetHandle($inp_url) Then
				Local $sText = GUICtrlRead($inp_url)
				Local $beginProt = StringLeft($sText, 5)
				If _isURL($sText) Then
					Cef_LoadURL($BrowserTabs[$CurTab][1], $sText)
				Else
					Cef_LoadURL($BrowserTabs[$CurTab][1], "https://www.google.com/search?q=" & $sText)
				EndIf
			EndIf
		Case $btn_newtab
			_CreateTab()
		Case $closeButton
;~ 			GUIDelete($hGUI)
;~ 			Exit
			ProcessClose(@AutoItPID)
		Case $btn_pin
			$pinned = Not $pinned
		Case $btn_back
			Cef_GoBack($BrowserTabs[$CurTab][1])
		Case $btn_next
			Cef_GoForward($BrowserTabs[$CurTab][1])
		Case $btn_reload
			Cef_Reload($BrowserTabs[$CurTab][1])
		Case $btn_closetab
			Local $onlineTabsCount = 0
			Local $nearestTab = 1
			Local $firstTab = 0
			Local $lastTab = $TabCount
			For $i = 1 To $TabCount
				If $BrowserTabs[$i][4] <> 'destroyed' Then
					If $firstTab = 0 Then $firstTab = $i
					$lastTab = $i
					$onlineTabsCount += 1
				EndIf
			Next
			If $onlineTabsCount > 1 Then
				$BrowserTabs[$CurTab][4] = 'destroyed' ; Tab closed
				_WinAPI_DestroyWindow(Cef_GetHandle($BrowserTabs[$CurTab][1]))
				For $i = $CurTab - 1 To 1 Step -1
					Local $found = 0
					For $j = $CurTab + 1 To $lastTab
						If $BrowserTabs[$i][4] <> 'destroyed' Then
							_ShowTab($i)
							$found = 1
							ExitLoop
						ElseIf $BrowserTabs[$j][4] <> 'destroyed' Then
							_ShowTab($j)
							$found = 1
							ExitLoop
						EndIf
					Next
					If $found Then ExitLoop
				Next
				_RenderTabs()
			EndIf
		Case $btn_facebook
			_CreateTab('https://facebook.com')
		Case $btn_messenger
			_CreateTab('https://messenger.com')
		Case $btn_gmail
			_CreateTab('https://gmail.com')
		Case $btn_settings
			Global $hSettingsGUI = GUICreate("Settings", 300, 150, -1, -1, -1, BitOR($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW))
			GUISetBkColor(0xFFFFFF)
			Global $start_with_win_cb = GUICtrlCreateCheckbox("Start with Windows", 20, 20, 260, 25)
			GUICtrlSetOnEvent(-1, "_Event_Settings")
			If RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run", "altersidebar") = @ScriptFullPath Then
				GUICtrlSetState($start_with_win_cb, $GUI_CHECKED)
			EndIf
			Global $cover_taskbar_cb = GUICtrlCreateCheckbox("Cover Taskbar (Require Restart SideBrowser)", 20, 60, 260, 25)
			GUICtrlSetOnEvent(-1, "_Event_Settings")
			If StorageRead('CoverTaskbar') = 1 Then
				GUICtrlSetState($cover_taskbar_cb, $GUI_CHECKED)
			EndIf
			Global $lb_author = GUICtrlCreateLabel("Created with love by @MonokaiJs", 20, 90, 260, 30)
			GUICtrlSetOnEvent(-1, "_Event_Settings")
			GUISetState(@SW_SHOW)
			GUISwitch($hSettingsGUI)
			GUISetOnEvent($GUI_EVENT_CLOSE, 'close_settings')
	EndSwitch
EndFunc   ;==>_Handle_Menu

Func close_settings()
	GUIDelete($hSettingsGUI)
	GUISwitch($hGUI)
EndFunc   ;==>close_settings

Func _CreateTab($url = "https://google.com")
	GUICtrlSetData($inp_url, $url)
	For $i = 1 To $TabCount
		If $BrowserTabs[$i][4] <> 'destroyed' Then
			_WinAPI_ShowWindow(Cef_GetHandle($BrowserTabs[$i][1]), @SW_HIDE)
		EndIf
	Next
	$TabCount += 1
	$BrowserTabs[$TabCount][1] = Cef_Init()
	$BrowserTabs[$i][8] = "new tab"
	Cef_Create($BrowserTabs[$TabCount][1], $hGUI, $url, $ButtonSize + 8, $ButtonSize * 2, $BrowserSize + $ButtonSize + 8, $GUIHeight)
	Cef_OnLoadStart($BrowserTabs[$TabCount][1], "_OnLoadStart")
	Cef_OnLoadEnd($BrowserTabs[$TabCount][1], "_OnLoadEnd")
	Cef_OnTitleChange($BrowserTabs[$TabCount][1], "_OnTitleChange")
	Cef_OnLoadEnd($BrowserTabs[$TabCount][1], "_OnLoadEnd")
	Cef_OnAddressChange($BrowserTabs[$TabCount][1], "_OnAddressChange")
	$CurTab = $TabCount
	_RenderTabs()
EndFunc   ;==>_CreateTab

Func _RenderTabs()
	For $i = 1 To $TabCount
		GUICtrlDelete($BrowserTabs[$i][2])
		GUICtrlDelete($BrowserTabs[$i][3])
	Next
	Local $countTab = 0
	For $i = 1 To $TabCount
		If $BrowserTabs[$i][4] <> 'destroyed' Then
			$countTab += 1
			$BrowserTabs[$i][2] = GUICtrlCreateLabel('', $ButtonSize + 8 + 150 * ($countTab - 1), 0, 150, $ButtonSize - 2, BitOR($SS_CENTER, $SS_CENTERIMAGE))
			_GUICtrl_OnHoverRegister(-1, "_Tab_Hover", "_Tab_Hover")
			SetOnEventA(-1, "_ShowTab", $paramByVal, $i)
			GUICtrlSetColor(-1, 0xFFFFFF)
			GUICtrlSetFont(-1, 10, 0, 0, "Segoe UI Light", 5)
			GUICtrlSetResizing(-1, 2 + 32 + 256 + 512)
			$BrowserTabs[$i][3] = GUICtrlCreateLabel("", $ButtonSize + 8 + 150 * ($countTab - 1), $ButtonSize - 2, 150, 2, BitOR($SS_CENTER, $SS_CENTERIMAGE))
			GUICtrlSetResizing(-1, 2 + 32 + 256 + 512)
			If $i = $CurTab Then
				GUICtrlSetBkColor(-1, 0x2980b9)
				GUICtrlSetFont(-1, 10, 0, 0, "Segoe UI Light", 5)
			Else
				GUICtrlSetBkColor(-1, 0xFFFFFF)
				GUICtrlSetFont(-1, 10, 0, 0, "Segoe UI Light", 5)
			EndIf
			$BrowserTabs[$i][13] = False
		EndIf
	Next
EndFunc   ;==>_RenderTabs

Func _CurFrameLoadURL($url)
;~ 	MsgBox(64, '', $url)
	Cef_LoadURL($BrowserTabs[$CurTab][1], $url)
	ConsoleWrite($url)
EndFunc   ;==>_CurFrameLoadURL

Func _ShowTab($TabID)
	$CurTab = $TabID
	GUICtrlSetData($inp_url, $BrowserTabs[$CurTab][7])
	_SetViewFrame()
EndFunc   ;==>_ShowTab

Func _SetViewFrame()
	For $i = 1 To $TabCount
		_WinAPI_ShowWindow(Cef_GetHandle($BrowserTabs[$i][1]), $i = $CurTab ? @SW_SHOW : @SW_HIDE)
	Next
	_RenderTabs()
EndFunc   ;==>_SetViewFrame

Func _Tab_Hover($cID, $cStat)
	If $cStat = 2 Then
		GUICtrlSetBkColor($cID, 0x191919)
		GUICtrlSetColor($cID, 0xFFFFFF)
		GUICtrlSetFont($cID, 10, 0, 0, "Segoe UI Light")
	Else
		GUICtrlSetBkColor($cID, 0x454545)
		GUICtrlSetColor($cID, 0xFFFFFF)
		GUICtrlSetFont($cID, 10, 0, 0, "Segoe UI Light")
	EndIf
EndFunc   ;==>_Tab_Hover

Func _CloseBtnHover($item, $status)
	If $status = 2 Then ; Not hovered
		GUICtrlSetBkColor($item, $closeButtonColor)
		GUICtrlSetFont($item, 16, 0, 0, 'arrowCI', 5)
	ElseIf Not $GUIResizing Then ; Hovering
		GUICtrlSetBkColor($item, $closeButtonColorHover)
		GUICtrlSetFont($item, 16, 0, 0, 'arrowCI', 5)
	EndIf
EndFunc   ;==>_CloseBtnHover

Func _Menu_Hover($item, $status)
	If $status = 2 Then ; Not hovered
		GUICtrlSetBkColor($item, 0x191919)
		GUICtrlSetFont($item, 16, 0, 0, 'arrowCI', 5)
	Else ; Hovering
		GUICtrlSetBkColor($item, 0x373737)
		GUICtrlSetFont($item, 16, 0, 0, 'arrowCI', 5)
	EndIf
EndFunc   ;==>_Menu_Hover

Func _Nav_Hover($item, $status)
	If $status = 2 Then ; Not hovered
		GUICtrlSetBkColor($item, 0x191919)
		GUICtrlSetFont($item, 12, 0, 0, 'arrowCI', 5)
	Else ; Hovering
		GUICtrlSetBkColor($item, 0x373737)
		GUICtrlSetFont($item, 12, 0, 0, 'arrowCI', 5)
	EndIf
EndFunc   ;==>_Nav_Hover

Func _Nav_BtnHover($item, $status)
	If $status = 2 Then ; Not hovered
		GUICtrlSetBkColor($item, 0x595959)
		GUICtrlSetFont($item, 10, 0, 0, 'arrowCI', 5)
	Else ; Hovering
		GUICtrlSetBkColor($item, 0x838383)
		GUICtrlSetFont($item, 10, 0, 0, 'arrowCI', 5)
	EndIf
EndFunc   ;==>_Nav_BtnHover

Func StorageRead($cf_name)
	Global $dat = RegRead("HKCU\Software\SideBrowser", $cf_name)
	If @error Then
		Return ""
	Else
		Return $dat
	EndIf
EndFunc   ;==>StorageRead

Func StorageWrite($cf_name, $cf_value)
	RegWrite("HKCU\Software\SideBrowser", $cf_name, "REG_SZ", $cf_value)
EndFunc   ;==>StorageWrite

Func _isURL($sString)
	Local $URL_Heads = "http|https|file|ftp|gopher|rtsp"
	Local $url = StringRegExp(GUICtrlRead($inp_url), "[" & $URL_Heads & "]\://(.*?)", 3, 1)
	Return IsArray($url)
EndFunc   ;==>_isURL

Func URLEncode($urlText)
	Local $url = ""
	For $i = 1 To StringLen($urlText)
		Local $acode = Asc(StringMid($urlText, $i, 1))
		Select
			Case ($acode >= 48 And $acode <= 57) Or _
					($acode >= 65 And $acode <= 90) Or _
					($acode >= 97 And $acode <= 122)
				$url = $url & StringMid($urlText, $i, 1)
			Case $acode = 32
				$url = $url & "+"
			Case Else
				$url = $url & "%" & Hex($acode, 2)
		EndSelect
	Next
	Return $url
EndFunc   ;==>URLEncode
