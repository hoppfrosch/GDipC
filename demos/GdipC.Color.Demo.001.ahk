#include %A_ScriptDir%\..\lib\gdipc\gdipc.ahk

col := GDipC.Color.new()

MsgBox col.a "-" col.r "-" col.g "-" col.b

ExitApp

