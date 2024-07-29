CitrixWindowName := "W11-STATIC - Desktop Viewer"
ChromeLoginWindowName := "NetScaler AAA - Google Chrome"
PasswordStoreCitrixKey := "AHK_CredentialsForCitrix"
global CanLogin := true

if (!CredRead(PasswordStoreCitrixKey))
{
    InputBox, CitrixUserName, Enter Name, Please enter username:, , 300, 150
    InputBox, CitrixPassword, Enter Password, Please enter password:, hide , 300, 150

    if !CredWrite(PasswordStoreCitrixKey, CitrixUserName, CitrixPassword)
        MsgBox Failed to write credentials
}

if (!(cred := CredRead(PasswordStoreCitrixKey)))
    MsgBox Credentials not found

; if !CredDelete(PasswordStoreCitrixKey)
;     MsgBox Failed to delete cred

Loop
{
    Sleep, 1000
    
    ; Comment this next line out in case you don't need to login in Chrome
    FindChromeLoginScreenAndLogin(cred)

    ; Now look for Citrix VM login screen
    If WinExist(CitrixWindowName)
    {
        ;MsgBox, "Will wait for window to be active"
        WinWaitActive, %CitrixWindowName%,,0.5

        ; Look for Pixel for loaded Window
        CoordMode, Pixel, Window
        PixelSearch, FoundX, FoundY, 12, 37, 12, 37, 0x3A4145, 15, Fast RGB
        If ErrorLevel
        {
            Continue
        }
        
        ; Resize
        WinGetPos, X, Y, Width, Height, %CitrixWindowName%
        Width := Width + 1
        WinMove, %CitrixWindowName%,, X, Y, Width, Height

        ; Look for login image
        Loop
        {
            CoordMode, Pixel, Window
            ImageSearch, FoundX, FoundY, 917, 400, 1459, 900, *15 images-to-find\login-screen-icon.png
            Sleep, 500
        }
        Until ErrorLevel = 0
        If ErrorLevel = 0
        {
            /*
            MsgBox, 0, , Active
            */
            Click, %FoundX%, %FoundY% Left, 1
            Sleep, 10
            Sleep, 200
            Send, ^a
            SendRaw, % cred.password
            Sleep, 200
            Send, {Enter}

            ; Resize back
            Sleep, 3000
            Width := Width - 1
            WinMove, %CitrixWindowName%,, X, Y, Width, Height
        }

        Sleep, 1000
        WinWaitClose, %CitrixWindowName%
        CanLogin := True
        ;MsgBox, "Window Closed"
    }
}

FindChromeLoginScreenAndLogin(cred)
{
    global CanLogin
    global CitrixWindowName, ChromeLoginWindowName
    If CanLogin = 0
    {
        Return
    }

    If WinExist(CitrixWindowName) or WinExist(ChromeLoginWindowName) = 0
    {
        Return
    }
    
    WinWaitActive, %ChromeLoginWindowName%,,0.5
    if ErrorLevel
    {
        Return
    }
    Sleep, 333
    CoordMode, Pixel, Window
    PixelSearch, FoundX, FoundY, 0, 0, 3440, 1440, 0x3C4B56, 15, Fast RGB
    If ErrorLevel = 0
    {
        findLoginResult := FindImage("images-to-find\login-button.png")
        If findLoginResult.ErrorLevel = 0
        {
            FoundY := findLoginResult.FoundY - 90
            FoundX := findLoginResult.FoundX + 30
            Click, %FoundX%, %FoundY% Left, 1
            Sleep, 300
            SendRaw, % cred.username
            Sleep, 10
            Send, {Tab}
            Sleep, 10
            SendRaw, % cred.password
            Sleep, 200
            Send, {Enter}

            ; Wait for login button to disappear
            Loop
            {
                findLoginResult := FindImage("images-to-find\login-finished.png")
            }
            Until findLoginResult.ErrorLevel = 0

            ; Find DESKTOP icon, click there
            ; Find W11 text, click there
            Loop
            {
                findLoginResult := FindImage("images-to-find\desktops.png")
            }
            Until findLoginResult.ErrorLevel = 0
            If findLoginResult.ErrorLevel = 0
            {
                FoundX := findLoginResult.FoundX
                FoundY := findLoginResult.FoundY
                Sleep, 200
                Click, %FoundX%, %FoundY% Left, 1
                

                Loop
                {
                    findLoginResult := FindImage("images-to-find\w11.png")
                }
                Until findLoginResult.ErrorLevel = 0
                If findLoginResult.ErrorLevel = 0
                {
                    FoundX := findLoginResult.FoundX+50
                    FoundY := findLoginResult.FoundY-20
                    Sleep, 200
                    Click, %FoundX%, %FoundY% Left, 1

                    ; Wait for existance and activate Citrix Window
                    WinWait, %CitrixWindowName%,,
                    WinActivate, %CitrixWindowName%,,
                }
            }

            ;MsgBox, "Login finished"
            CanLogin := False
        }
    }

}

FindImage(path)
{
    CoordMode, Pixel, Window
    ImageSearch, FoundX, FoundY, 0, 0, 3440, 1440, *15 %path%
    return {ErrorLevel: ErrorLevel, FoundX: FoundX, FoundY: FoundY}
}

CredWrite(name, username, password)
{
    VarSetCapacity(cred, 24 + A_PtrSize * 7, 0)
    cbPassword := StrLen(password)*2
    NumPut(1         , cred,  4+A_PtrSize*0, "UInt") ; Type = CRED_TYPE_GENERIC
    NumPut(&name     , cred,  8+A_PtrSize*0, "Ptr")  ; TargetName = name
    NumPut(cbPassword, cred, 16+A_PtrSize*2, "UInt") ; CredentialBlobSize
    NumPut(&password , cred, 16+A_PtrSize*3, "UInt") ; CredentialBlob
    NumPut(3         , cred, 16+A_PtrSize*4, "UInt") ; Persist = CRED_PERSIST_ENTERPRISE (roam across domain)
    NumPut(&username , cred, 24+A_PtrSize*6, "Ptr")  ; UserName
    return DllCall("Advapi32.dll\CredWriteW"
    , "Ptr", &cred ; [in] PCREDENTIALW Credential
    , "UInt", 0    ; [in] DWORD        Flags
    , "UInt") ; BOOL
}

CredDelete(name)
{
    return DllCall("Advapi32.dll\CredDeleteW"
    , "WStr", name ; [in] LPCWSTR TargetName
    , "UInt", 1    ; [in] DWORD   Type,
    , "UInt", 0    ; [in] DWORD   Flags
    , "UInt") ; BOOL
}

CredRead(name)
{
    DllCall("Advapi32.dll\CredReadW"
    , "Str", name   ; [in]  LPCWSTR      TargetName
    , "UInt", 1     ; [in]  DWORD        Type = CRED_TYPE_GENERIC (https://learn.microsoft.com/en-us/windows/win32/api/wincred/ns-wincred-credentiala)
    , "UInt", 0     ; [in]  DWORD        Flags
    , "Ptr*", pCred ; [out] PCREDENTIALW *Credential
    , "UInt") ; BOOL
    if !pCred
        return
    name := StrGet(NumGet(pCred + 8 + A_PtrSize * 0, "UPtr"), 256, "UTF-16")
    username := StrGet(NumGet(pCred + 24 + A_PtrSize * 6, "UPtr"), 256, "UTF-16")
    len := NumGet(pCred + 16 + A_PtrSize * 2, "UInt")
    password := StrGet(NumGet(pCred + 16 + A_PtrSize * 3, "UPtr"), len/2, "UTF-16")
    DllCall("Advapi32.dll\CredFree", "Ptr", pCred)
    return {"name": name, "username": username, "password": password}
}