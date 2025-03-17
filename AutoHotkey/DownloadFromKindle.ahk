#Requires AutoHotKey v2.0

Esc::ExitApp
EmptyPath := "empty.png"
ScrollbarPath := "scrollbar.png"
LimitPath := "limit.png"
DownloadingPath := "downloading.png"
PendingPath := "pending.png"
SyncPath := "sync.png"
ExportPath := A_MyDocuments "\Kindle Export"
AzwPath := A_MyDocuments "\My Kindle Content\*.azw"
AmznKuCentralUrl := "https://www.amazon.co.jp/kindle-dbs/ku/ku-central/?current&return&ids="

; How many times to try scrolling down before giving up
; Depending on the window size and amount of items,
; it's unpredictable if there is a scroll bar or not.
; It easy to detect if we are at the bottom if the scroll bar exists,
; but hard to detect if it doesn't so we set a maximum limit and just try exhaustively
ScrollDownTries := 30
ScrollDelay := 500
Fluff := 30
MainX := 230 + Fluff
MainY := 145 + Fluff

IsScrolledDown()
{
    return ImageSearch(&X, &Y, MainX, WinHeight - 50, Width, 50, ScrollbarPath)
}

ScrollUp()
{
    MouseMove MainX, MainY
    Click "WheelUp 50"
    sleep ScrollDelay
}

ScrollBitDown()
{
    MouseMove MainX, MainY
    Click "WheelDown 3"
    sleep ScrollDelay
}

Sync()
{
    MouseMove 400, 50
    Click
    Loop 10 {
        sleep 500
        Found := ImageSearch(&X, &Y, 0, 0, WinWidth, MainY, SyncPath)
    }
}

; Expecting the Greasemonkey scripts to be installed and working in Firefox
ReturnKindleUnlimited(asins)
{
    Run "firefox.exe -new-window " AmznKuCentralUrl asins
    sleep 20000
    WinClose "Mozilla Firefox"
}

; The Kindle Windows app is quite buggy,
; and sometimes it continues to show titles with expired licenses
; so we need to dismiss those
DismissLimitWarning()
{
    Found := ImageSearch(&LimitX, &LimitY, MainX, MainY, Width, Height, LimitPath)
    if (Found) {
        MouseMove LimitX + 30, LimitY + 310
        Click
    }
}

NumReadyFiles()
{
    Num := 0
    Loop Files, AzwPath, "R" {
        ; We check for the size because don't want to count empty files
        ; that are just placeholders for the DL
        if (A_LoopFileSize > 0) {
            Num := Num + 1
        }
    }
    return Num
}

GetAsin(fname)
{
    ; file name format: B0ACABACAB_EBOK.azw
    return StrSplit(fname, "_")[1]
}

Loop {
    WinActivate "ahk_exe Kindle.exe"
    WinGetClientPos &X, &Y, &WinWidth, &WinHeight, "ahk_exe Kindle.exe"
    Width := WinWidth - MainX
    Height := WinHeight - MainY

    Sync

    EverythingComplete := true

    ; Looking for titles that are not yet downloaded or downloading
    ScrollUp
    Loop ScrollDownTries {
        DismissLimitWarning

        FoundPending := ImageSearch(&X, &Y, MainX, MainY, Width, Height, PendingPath)
        FoundDownloading := ImageSearch(&X, &Y, MainX, MainY, Width, Height, DownloadingPath)
        FoundEmpty := ImageSearch(&EmptyX, &EmptyY, MainX, MainY, Width, Height, EmptyPath)

        if (FoundPending || FoundDownloading || FoundEmpty) {
            EverythingComplete := false
        }

        if (FoundEmpty) {
            MouseMove EmptyX, EmptyY + 40
            Click "Left 2"
            sleep 100
        }

        if (IsScrolledDown()) {
            break
        }

        ScrollBitDown
    }

    ; Looking if there are still downloads pending
    if (NumReadyFiles() >= 1 && EverythingComplete) {
        asins := ""
        Loop Files, AzwPath, "R" {
            if (A_LoopFileSize > 0) {
                asins := asins GetAsin(A_LoopFileName) ","
                FileCopy A_LoopFilePath, ExportPath, 1
            } else {
                MsgBox "Unexpected zero size file"
                break
            }
        }
        TrayTip "Returning " asins
        ReturnKindleUnlimited asins
        Sync
    }

    sleep 5000
}
