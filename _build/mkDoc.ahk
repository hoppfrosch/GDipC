#Include %A_ScriptDir%\..\lib\GDipC.ahk  ; Where to get version being used within documentation
obj := GDipC()


; Omit extension ".exe" 
NDPath := GetFullPathName(A_ScriptDir "\..\..\_build\NaturalDocs\NaturalDocs")

DocuUpdateVersion(obj.version, A_ScriptDir)
DocuGenerate(A_ScriptDir)
ChangelogGenerate(A_ScriptDir)
ExitApp

;-------------------------------------------------------------------------------------------------------------
DocuUpdateVersion(ver, path) {
	; Updates Version (within NaturalDocs project file) within documentation

	NDProjectFile := GetFullPathName(path "\NDProj\project.txt")
	NDProjectFileTmp := NDProjectFile ".tmp"
	fileOut := FileOpen(NDProjectFileTmp, "w")

	fileIn := FileOpen(NDProjectFile,"r")
	while (!fileIn.AtEOF) {
		line := fileIn.ReadLine()
		if (foundPos := RegExMatch(line, "Subtitle\:")) {
			line := "Subtitle: Version " ver
		}
		fileOut.Write(line "`n")
	}

	fileIn.close()
	fileOut.close()
	FileMove NDProjectFileTmp, NDProjectFile, 1
}

;-------------------------------------------------------------------------------------------------------------
DocuGenerate(path) {
	; Generates Documentation using NaturalDocs
	EnvSet "NDPATH", NDPath
	cmd := NDPath " -r -p " path "\NDProj"
	RunWait(cmd)
}

;-------------------------------------------------------------------------------------------------------------
ChangelogGenerate(path) {
	; Generates Changelog using git-cliff
	tmp := A_WorkingDir
	SetWorkingDir A_ScriptDir "\.."
	cmd := "git cliff"
	cmd := cmd " -o .\CHANGELOG.md"
	RunWait(cmd,,"Min")
	SetWorkingDir tmp
}	

;-------------------------------------------------------------------------------------------------------------
GetFullPathName(Filename) {
	; Determines the fullpath (absolute path) from relative path
	Size := DllCall("Kernel32.dll\GetFullPathNameW", "Str", Filename, "UInt", 0, "Ptr", 0, "PtrP", 0)
	OutputBuff := Buffer(Size * 2)
	r := DllCall("Kernel32.dll\GetFullPathNameW", "Str", Filename, "UInt", Size, "Ptr", OutputBuff, "PtrP", 0)
	ret := ""
	if (r > 0)
		ret := RTrim(StrGet(OutputBuff), "\")
	Else
		ret := Filename
	return ret
}

