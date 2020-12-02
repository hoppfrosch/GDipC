#include %A_ScriptDir%\..\lib\gdipc\gdipc.ahk
#include %A_ScriptDir%\..\lib\gdipc\gdipcex.ahk

pt1 := GdipC.Point.new()
pt2 := GdipCEx.Point.new()
; pt := GdipCEx.Point.fromMouse()
x := pt2.toJSON()
MsgBox x
pt3 := GdipCEx.Point.fromJSON(x)
ExitApp

