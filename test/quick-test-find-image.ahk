Loop
{
    Sleep, 1000
    
    ; Find DESKTOP icon, click there
    ; Find W11 text, click there
    Loop
    {
        findLoginResult := FindImage("..\images-to-find\desktops.png")
    }
    Until findLoginResult.ErrorLevel = 0
    If findLoginResult.ErrorLevel = 0
    {
        MsgBox, "Found at X: " findLoginResult.FoundX " and Y: " findLoginResult.FoundY
    }
    
}

FindImage(path)
{
    CoordMode, Pixel, Window
    ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *40 %path%
    return {ErrorLevel: ErrorLevel, FoundX: FoundX, FoundY: FoundY}
}