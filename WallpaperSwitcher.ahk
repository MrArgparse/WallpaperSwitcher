#Requires AutoHotkey v2.0

WALLPAPERS := []
PATH := "C:/Users/-/Pictures/Wallpapers/"
CURRENT_INDEX := 0

; Function to collect wallpapers from the specified directory and extensions
CollectWallpapers(dir, extensions) {
	global WALLPAPERS

	for ext in extensions {
		pattern := dir "\*." . ext
		Loop Files, pattern
			WALLPAPERS.Push(A_LoopFileFullPath)
	}
}

; Collect wallpapers
CollectWallpapers(PATH, ["bmp", "png", "jpg", "jpeg", "webp"])
FILECOUNT := WALLPAPERS.Length
; Flag to track if the error message box is open
IS_ERROR_MSG_OPEN := false  

; Function to set the desktop wallpaper
SetDesktopWallpaper(imagePath) {
	return DllCall("user32.dll\SystemParametersInfo", "UInt", 0x0014, "UInt", 0, "Ptr", StrPtr(imagePath), "UInt", 1)
}

; Function to handle common error checks
CheckErrors() {
	global PATH, FILECOUNT, IS_ERROR_MSG_OPEN
	if !FileExist(PATH) {
		ShowErrorMsg("Directory not found: " PATH)
		return false
	} 

	if (FILECOUNT = 0) {
		ShowErrorMsg("No image files in directory: " PATH "`nAccepted formats are: bmp, png, jpg, jpeg, webp.")
		return false
	} 

	return true
}

; Function to show error messages with handling for single instance
ShowErrorMsg(message) {
	global IS_ERROR_MSG_OPEN

	if !IS_ERROR_MSG_OPEN {
		IS_ERROR_MSG_OPEN := true
		MsgBox message
		IS_ERROR_MSG_OPEN := false
	}
}

; Hotkey to cycle forward (Ctrl + Alt + Right Arrow)
^!Right:: {
	global CURRENT_INDEX, FILECOUNT, WALLPAPERS

	if !CheckErrors() {
		return
	}

	CURRENT_INDEX := Mod(CURRENT_INDEX, FILECOUNT) + 1
	SetDesktopWallpaper(WALLPAPERS[CURRENT_INDEX])
}

; Hotkey to cycle backward (Ctrl + Alt + Left Arrow)
^!Left:: {
	global CURRENT_INDEX, FILECOUNT, WALLPAPERS

	if !CheckErrors() {
		return
	}

	CURRENT_INDEX := Mod(CURRENT_INDEX - 2 + FILECOUNT, FILECOUNT) + 1
	SetDesktopWallpaper(WALLPAPERS[CURRENT_INDEX])
}

; Reload Script
A_TrayMenu.Add
A_TrayMenu.Add 'Reload this script', (itemName, itemPos, m) => Reload()