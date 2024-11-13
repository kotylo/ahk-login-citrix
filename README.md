# ahk-login-citrix
AHK Script to Login into Windows 11 Citrix VM in case autologin has been disabled.

## How it works?

It searches for some images in `images-to-find` folder (you can edit them if they differ) and enters the password, prompted and stored on the first execution in the Windows Credentials Store.

> **Note:**
To modify or delete the password, run the following command in Win+R: `control.exe keymgr.dll` → Windows Credentials → `AHK_CredentialsForCitrix`. There is no mechanism to remove it automatically yet, in case login fails, for example.

If we see the login screen of Windows 11, the password will be entered after window is active and Enter key will be pressed.

Now, in order to find out if that has been successfull, i had to resize window by 1 pixel and back after logging in, therefore the flicker will occur. I couldn't find why ImageSearch doesn't work in AHK otherwise, but it must be something with refreshing the window. If you have more insight, Pull Requests are welcome.

Afterwards we're waiting for the VM Window to be closed and opened again in order to start looking for password again. So it won't use unnecesary resourcec or trigger in case you have manually locked the user.

## Configuration

Basically no need to configure anything if all goes well.

### Screen Size
I have widescreen monitor, so you might have to change the max resolution for methods like `PixelSearch` and `ImageSearch` to look for images.

### Disable login in Chrome
Script includes possibility to automatically type your credentials in Web Interface for Login, additionally to the VM itself. You can disable this by commenting out the following line:

```
; Comment this next line out in case you don't need to login in Chrome
    FindChromeLoginScreenAndLogin(cred)
```

### Runing
Just clone, install [AHK](https://www.autohotkey.com/download/ahk-v2.exe) and paste the shortcut of ahk file into Win+R → `shell:startup` folder.

## Changes
- 2024-07-29: Fixed new icon and added activation of Citrix window