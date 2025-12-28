/**
 * @description: Functions for automating the Roblox window
 */

; Updates global variables windowX, windowY, windowWidth, windowHeight
; Optionally takes a known window handle to skip GetRobloxHWND call
; Returns: 1 = successful; 0 = TargetError
GetRobloxClientPos(hwnd?) {
    global windowX, windowY, windowWidth, windowHeight
    if (!IsSet(hwnd)) {
        hwnd := GetRobloxHWND()
    }

    try {
        WinGetClientPos(&windowX, &windowY, &windowWidth, &windowHeight, "ahk_id " hwnd)
    } catch TargetError
        return windowX := windowY := windowWidth := windowHeight := 0
    else {
        return 1
    }
}

; Returns: hWnd = successful; 0 = window not found
GetRobloxHWND() {
    if (hwnd := WinExist("Roblox ahk_exe RobloxPlayerBeta.exe"))
        return hwnd
    else if (WinExist("Roblox ahk_exe ApplicationFrameHost.exe")) {
        try
            hwnd := ControlGetHwnd("ApplicationFrameInputSinkWindow1")
        catch TargetError
            hwnd := 0
        return hwnd
    }
    else
        return 0
}

; Finds the y-offset of GUI elements in the current Roblox window
; Optionally takes a known window handle to skip GetRobloxHWND() call
; Returns: offset (integer), defaults to 0 on fail (ByRef param fail is then set to 1, else 0)
GetYOffset(hwnd?, &fail?) {
    static hRoblox := 0, offset := 0

    if (!IsSet(hwnd)) {
        hwnd := GetRobloxHWND()
    }

    if hwnd = hRoblox {
        fail := 0
        return offset
    } else if WinExist("ahk_id " hwnd) {
        try {
            WinActivate("Roblox")
        }
        GetRobloxClientPos(hwnd)

        outerLoopCount := 0
        loop 3 {
            outerLoopCount++
            pBMScreen := Gdip_BitmapFromScreen((IsSet(windowDimensions) ? windowDimensions : windowX "|" (IsSet(offsetY
            ) ? (windowY + offsetY) : windowY) "|" windowWidth "|" (IsSet(offsetY) ? (windowHeight - offsetY) :
                windowHeight)))

            loop 20 {
                searchResult := Gdip_ImageSearch(pBMScreen, bitmaps["topbutton"], &pos, , , , , 20)

                if (searchResult = 1) {
                    x := SubStr(pos, 1, (comma := InStr(pos, ",")) - 1)
                    y := SubStr(pos, comma + 1)
                    fillResult := Gdip_ImageSearch(pBMScreen, bitmaps["topbuttonfill"], , x, y, x + 34, y + 31, 20)

                    if (fillResult = 0) {
                        Gdip_DisposeImage(pBMScreen)
                        hRoblox := hwnd
                        fail := 0
                        return offset := y - 14
                    }
                }

                if A_Index = 20 {
                    Gdip_DisposeImage(pBMScreen)
                    if outerLoopCount = 3 {
                        fail := 1
                        return 0
                    }
                    break
                } else {
                    Sleep 50
                }
            }

            Gdip_DisposeImage(pBMScreen)
            Sleep 100
        }

        fail := 1
        return 0

    } else {
        fail := 1
        return 0
    }
}

; Activate the Roblox window
ActivateRoblox() {
    try {
        WinActivate("Roblox")
    } catch {
        return 0
    } else {
        return 1
    }
}
