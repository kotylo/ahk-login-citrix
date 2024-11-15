CitrixWindowName := "W11-STATIC - Desktop Viewer"
ChromeLoginWindowName := "NetScaler AAA - Google Chrome"

Loop
{
    Sleep, 1000
    
    ; Find DESKTOP icon, click there
    ; Find W11 text, click there
    Loop
    {
        findLoginResult := FindImage("images-to-find\desktops.png")
    }
    Until findLoginResult.ErrorLevel = 0
    If findLoginResult.ErrorLevel = 0
    {
        MsgBox, "Found"
    }
    
}

FindImage(path)
{
    CoordMode, Pixel, Window
    ImageSearch, FoundX, FoundY, 0, 0, 3440, 1440, *40 %path%
    return {ErrorLevel: ErrorLevel, FoundX: FoundX, FoundY: FoundY}
}