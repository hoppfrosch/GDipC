#Include %A_ScriptDir%\..\lib\GdipC\GdipC.ahk  ; Where to get version to be used within documentation
#include %A_ScriptDir%\BuildTools.ahk

DocuUpdateVersion(release_version())
DocuGenerate()

ExitApp