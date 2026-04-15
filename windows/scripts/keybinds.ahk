#Requires AutoHotkey v2.0

; ==============================================================================
; Keybinds
; ==============================================================================

; Win + Q: Close active window
#q:: PostMessage(0x0010, 0, 0, , "A")

; Win + Shift + Q: Force quit
#+q::
{
    activePID := WinGetPID("A")
    ProcessClose(activePID)
}

; Win + F: Open Notepad++
#f:: Run "notepad++.exe"

; Win + T: Open Terminal
#t:: Run "wt.exe"

; Win + W: Open Firefox
#w:: Run "firefox.exe"

; ==============================================================================
; Horizontal Scrolling (Shift + Scroll)
; ==============================================================================
; Shift + Scroll Up: Scroll Left
+WheelUp::
{
    Send "{WheelLeft}"
}

; Shift + Scroll Down: Scroll Right
+WheelDown::
{
    Send "{WheelRight}"
}

; ==============================================================================
; Window Transparency Control (Ctrl + Shift + Scroll)
; ==============================================================================
^+WheelUp:: {
    MouseGetPos(, , &win)

    try {
        Trans := WinGetTransparent(win)
    } catch {
        return
    }

    if (Trans = "")
        Trans := 255

    newTrans := Trans + 15

    if (newTrans > 255)
        newTrans := 255

    WinSetTransparent(newTrans, win)
}

^+WheelDown:: {
    MouseGetPos(, , &win)

    try {
        Trans := WinGetTransparent(win)
    } catch {
        return
    }

    if (Trans = "")
        Trans := 255

    newTrans := Trans - 15

    if (newTrans < 75)
        newTrans := 75

    WinSetTransparent(newTrans, win)
}

; ==============================================================================
; Window Dragging
; ==============================================================================
;  Alt + Left Button  : Drag to move a window
;  Alt + Right Button : Drag to resize a window
;  Double-Alt + Left Button   : Minimize a window
;  Double-Alt + Right Button  : Maximize/Restore a window
;  Double-Alt + Middle Button : Close a window

SetWinDelay 1
CoordMode "Mouse"

g_DoubleAlt := false

!LButton::
{
    global g_DoubleAlt
    if g_DoubleAlt {
        MouseGetPos , , &KDE_id
        ; This message is mostly equivalent to WinMinimize,
        ; but it avoids a bug with PSPad.
        PostMessage 0x0112, 0xf020, , , KDE_id
        g_DoubleAlt := false
        return
    }

    MouseGetPos &KDE_X1, &KDE_Y1, &KDE_id
    if WinGetMinMax(KDE_id)
        return

    WinGetPos &KDE_WinX1, &KDE_WinY1, , , KDE_id
    loop {
        if !GetKeyState("LButton", "P")
            break
        MouseGetPos &KDE_X2, &KDE_Y2
        KDE_X2 -= KDE_X1
        KDE_Y2 -= KDE_Y1
        KDE_WinX2 := (KDE_WinX1 + KDE_X2)
        KDE_WinY2 := (KDE_WinY1 + KDE_Y2)
        WinMove KDE_WinX2, KDE_WinY2, , , KDE_id
    }
}

!RButton::
{
    global g_DoubleAlt
    if g_DoubleAlt {
        MouseGetPos , , &KDE_id
        if WinGetMinMax(KDE_id)
            WinRestore KDE_id
        else
            WinMaximize KDE_id
        g_DoubleAlt := false
        return
    }

    MouseGetPos &KDE_X1, &KDE_Y1, &KDE_id
    if WinGetMinMax(KDE_id)
        return

    WinGetPos &KDE_WinX1, &KDE_WinY1, &KDE_WinW, &KDE_WinH, KDE_id

    if (KDE_X1 < KDE_WinX1 + KDE_WinW / 2)
        KDE_WinLeft := 1
    else
        KDE_WinLeft := -1
    if (KDE_Y1 < KDE_WinY1 + KDE_WinH / 2)
        KDE_WinUp := 1
    else
        KDE_WinUp := -1
    loop {
        if !GetKeyState("RButton", "P")
            break
        MouseGetPos &KDE_X2, &KDE_Y2

        WinGetPos &KDE_WinX1, &KDE_WinY1, &KDE_WinW, &KDE_WinH, KDE_id
        KDE_X2 -= KDE_X1
        KDE_Y2 -= KDE_Y1

        WinMove KDE_WinX1 + (KDE_WinLeft + 1) / 2 * KDE_X2  ; X of resized window
        , KDE_WinY1 + (KDE_WinUp + 1) / 2 * KDE_Y2  ; Y of resized window
        , KDE_WinW - KDE_WinLeft * KDE_X2  ; W of resized window
        , KDE_WinH - KDE_WinUp * KDE_Y2  ; H of resized window
        , KDE_id
        KDE_X1 := (KDE_X2 + KDE_X1)
        KDE_Y1 := (KDE_Y2 + KDE_Y1)
    }
}

!MButton::
{
    global g_DoubleAlt
    if g_DoubleAlt {
        MouseGetPos , , &KDE_id
        WinClose KDE_id
        g_DoubleAlt := false
        return
    }
}

~Alt::
{
    global g_DoubleAlt := (A_PriorHotkey = "~Alt" and A_TimeSincePriorHotkey < 400)
    Sleep 0
    KeyWait "Alt"
}
