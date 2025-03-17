#Requires AutoHotKey v2.0

Esc::ExitApp
PristinePath := "pristine.png"
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
ScrollDownTries := 20
ScrollDelay := 500
ClickDelay := 100
Fluff := 30
MainX := 230
MainY := 145

UpdateWindowMeasurements() {
    global Width
    global Height
    WinActivate "ahk_exe Kindle.exe"
    WinGetClientPos &X, &Y, &Width, &Height, "ahk_exe Kindle.exe"
}

IsScrolledDown() {
    return ImageSearch(&X, &Y, Width - 50, Height - 50, Width, Height, ScrollbarPath)
}

ScrollUp() {
    MouseMove MainX + Fluff, MainY + Fluff
    Click "WheelUp 60"
    sleep ScrollDelay
}

ScrollBitDown() {
    MouseMove MainX + Fluff, MainY + Fluff
    Click "WheelDown 3"
    sleep ScrollDelay
}

Sync() {
    MouseMove 400, 50
    Click
    Loop 40 {
        sleep 500
        Found := ImageSearch(&X, &Y, 0, 0, Width, Height, SyncPath)
        if Found {
            break
        }
    }
}

; Expecting the Greasemonkey scripts to be installed and working in Firefox
ReturnKindleUnlimited(asins) {
    Run "firefox.exe -new-window " AmznKuCentralUrl asins
    sleep 20000
    WinClose "Mozilla Firefox"
}

; The Kindle Windows app is quite buggy,
; and sometimes it continues to show titles with expired licenses
; so we need to dismiss those
DismissLimitWarning() {
    Loop {
        Found := ImageSearch(&LimitX, &LimitY, 0, 0, Width, Height, LimitPath)
        if Found {
            MouseMove LimitX + 30, LimitY + 310
            Click
            sleep ClickDelay
        } else {
            break
        }
    }
}

NumReadyFiles() {
    Num := 0
    Loop Files, AzwPath, "R" {
        ; We check for the size because don't want to count empty files
        ; that are just placeholders for the DL
        if A_LoopFileSize > 0 {
            Num := Num + 1
        }
    }
    return Num
}

GetAsin(fname) {
    ; file name format: B0ACABACAB_EBOK.azw
    return StrSplit(fname, "_")[1]
}


; Main loop
Loop {
    UpdateWindowMeasurements
    Sync

    EverythingDone := true
    ScrollUp
    ; Scroll down loop: looking for titles that are not yet downloaded or downloading
    Loop ScrollDownTries {
        DismissLimitWarning ; for asynchronously popping warnings (pending download triggering it)

        FoundPending := ImageSearch(&X, &Y, MainX, MainY, Width, Height, PendingPath)
        FoundDownloading := ImageSearch(&X, &Y, MainX, MainY, Width, Height, DownloadingPath)
        if FoundPending || FoundDownloading {
            EverythingDone := false
        }

        PristineY := MainY
        ; Scan loop: scanning the current view / scroll position to find non-clicked titles
        Loop {
            FoundPristine := ImageSearch(&PristineX, &PristineY, MainX, PristineY, Width, Height, PristinePath)
            if !FoundPristine {
                break
            }

            EverythingDone := false
            PristineY := PristineY + Fluff ; Going a bit further down for scanning for the next title, and clicking
            MouseMove PristineX, PristineY
            Click "Left 2"
            sleep ClickDelay
            DismissLimitWarning ; for warnings resulting directly from the click
        }

        if IsScrolledDown() {
            break
        }

        ScrollBitDown
    }

    ; Looking if there are still downloads pending
    if NumReadyFiles() > 0 && EverythingDone {
        Asins := ""
        Num := 0
        Loop Files, AzwPath, "R" {
            if A_LoopFileSize > 0 {
                Num := Num + 1
                Asins := Asins GetAsin(A_LoopFileName) ","
                FileCopy A_LoopFilePath, ExportPath, 1
            } else {
                MsgBox "Unexpected zero size file"
                break
            }
        }
        Asins := RTrim(Asins, ",")
        TrayTip "Returning " Num " titles: " StrReplace(Asins, ",", ", ")
        ReturnKindleUnlimited Asins
        Sync
    }

    sleep 5000
}
