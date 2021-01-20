#include %A_ScriptDir%\..\lib\gdipc\gdipc.ahk

col := GDipC.Color()

MsgBox col.a "-" col.r "-" col.g "-" col.b

ExitApp

