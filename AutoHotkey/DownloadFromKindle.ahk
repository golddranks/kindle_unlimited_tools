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

ReturnKindleUnlimited(ids)
{
    Run "firefox.exe -new-window " AmznKuCentralUrl ids
    sleep 15000
    WinClose "Mozilla Firefox"
}

DismissLimitWarning()
{
    Found := ImageSearch(&LimitX, &LimitY, 300, 155, Width, Height, LimitPath)
    if (Found) {
        MouseMove LimitX + 30, LimitY + 310
        Click
    }
}

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

Loop {
    Sync

    ScrollUp
    Loop 30 {
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

    if (NumFiles() >= 5) {
        ScrollUp
        Loop 30 {
            FoundPending := ImageSearch(&X, &Y, 300, 155, Width, Height, PendingPath)
            FoundDownloading := ImageSearch(&X, &Y, 300, 155, Width, Height, DownloadingPath)
            if (FoundPending || FoundDownloading) {
                break
            }

            if (IsScrolledDown()) {
                TrayTip "All files downloaded."
                ids := ""
                Loop Files, AzwPath, "R" {
                    if (A_LoopFileSize > 0) {
                        ids := ids StrSplit(A_LoopFileName, "_")[1] ","
                        FileCopy A_LoopFilePath, ExportPath, 1
                    } else {
                        MsgBox "Unexpected zero size file"
                        break
                    }
                }
                TrayTip "Returning " ids
                ReturnKindleUnlimited ids
                Sync
                sleep 5000
                break
            }
            ScrollBitDown
        }
    }

    sleep 5000
}
