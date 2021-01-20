#include %A_ScriptDir%\..\lib\gdipc\gdipc.ahk
#include %A_ScriptDir%\..\lib\gdipc\gdipcex.ahk
#include %A_ScriptDir%\..\lib\tby\classhelper.ahk

pt1 := GdipC.Point()
pt2 := GdipCEx.Point(42, 17)

; Serialize class to JSON
x := ClassHelper.toJSON(pt2)

; Create a new class instance by deserializing JSON
pt3 := ClassHelper.newFromJSON(x)
ExitApp

