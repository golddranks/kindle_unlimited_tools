#Requires AutoHotKey v2.0

Esc::ExitApp
EmptyPath := "empty.png"
ScrollbarPath := "scrollbar.png"
LimitPath := "limit.png"
DownloadingPath := "downloading.png"
PendingPath := "pending.png"
WinActivate "ahk_exe Kindle.exe"
WinGetClientPos &WinX, &WinY, &Width, &Height, "ahk_exe Kindle.exe"
ExportPath := A_MyDocuments "\Kindle Export"
AzwPath := A_MyDocuments "\My Kindle Content\*.azw"
AmznKuCentralUrl := "https://www.amazon.co.jp/kindle-dbs/ku/ku-central/?current&return&ids="

; How many times to try scrolling down before giving up
; Depending on the window size and amount of items,
; it's unpredictable if there is a scroll bar or not.
; It easy to detect if we are at the bottom if the scroll bar exists,
; but hard to detect if it doesn't so we set a maximum limit and just try exhaustively
ScrollDownTries := 30

IsScrolledDown()
{
    return ImageSearch(&EmptyX, &EmptyY, 300, Height - 50, Width, Height, ScrollbarPath)
}

ScrollUp()
{
    MouseMove 400, 200
    Click "WheelUp 50"
    sleep 500
}

ScrollBitDown()
{
    MouseMove 400, 200
    Click "WheelDown 3"
    sleep 500
}

Sync()
{
    MouseMove 400, 50
    Click
}

; Note: This URL expects the Greasemonkey scripts to be installed and working
ReturnKindleUnlimited(ids)
{
    Run "firefox.exe -new-window " AmznKuCentralUrl ids
    sleep 15000
    WinClose "Mozilla Firefox"
}

; The Kindle Windows app is quite buggy,
; and sometimes it continues to show titles with expired licenses
DismissLimitWarning()
{
    Found := ImageSearch(&LimitX, &LimitY, 300, 155, Width, Height, LimitPath)
    if (Found) {
        MouseMove LimitX + 30, LimitY + 310
        Click
    }
}

; We check for the size because don't want to count files that are just placeholders for the DL
NumFiles()
{
    Num := 0
    Loop Files, AzwPath, "R" {
        if (A_LoopFileSize > 0) {
            Num := Num + 1
        }
    }
    return Num
}

; file name format: B0ACABACAB_EBOK.azw
GetId(fname)
{
    return StrSplit(fname, "_")[1]
}

Loop {
    Sync

    ; Looking for files that are not yet downloaded or downloading
    ScrollUp
    Loop ScrollDownTries {
        sleep 100
        DismissLimitWarning
        Found := ImageSearch(&EmptyX, &EmptyY, 300, 155, Width, Height, EmptyPath)
        if (Found) {
            MouseMove EmptyX, EmptyY + 40
            Click "Left 2"
        } else {
            if (IsScrolledDown()) {
                break
            }
            ScrollBitDown
        }
    }

    ; Looking if there are still downloads pending
    if (NumFiles() >= 1) {
        EverythingComplete := true
        ScrollUp
        Loop ScrollDownTries {
            FoundPending := ImageSearch(&X, &Y, 300, 155, Width, Height, PendingPath)
            FoundDownloading := ImageSearch(&X, &Y, 300, 155, Width, Height, DownloadingPath)
            if (FoundPending || FoundDownloading) {
                EverythingComplete := false
                break
            }

            if (IsScrolledDown()) {
                break
            }

            ScrollBitDown
        }
        if (EverythingComplete) {
            TrayTip "All files downloaded."
            ids := ""
            Loop Files, AzwPath, "R" {
                if (A_LoopFileSize > 0) {
                    ids := ids GetId(A_LoopFileName) ","
                    FileCopy A_LoopFilePath, ExportPath, 1
                } else {
                    MsgBox "Unexpected zero size file"
                    break
                }
            }
            TrayTip "Returning " ids
            ReturnKindleUnlimited ids
            Sync
            ; We want to wait a bit for they sync so that this loop doesn't run again
            sleep 5000
        }
    }

    sleep 5000
}
