;-------------------------------------------------------------------------------------------------------------
DocuUpdateVersion(ver) {
	; Updates Version (within NaturalDocs project file) within documentation 

	NDProjectFile := GetFullPathName(A_ScriptDir "\NDProj\project.txt")
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
DocuGenerate() {
	; Generates Documentation using NaturalDocs
	EnvSet "NDPATH", GetFullPathName(A_ScriptDir "\NaturalDocs") 
	cmd := GetFullPathName(A_ScriptDir "\NaturalDocs\NaturalDocs") " -r -p .\NDProj"
	RunWait(GetFullPathName(A_ScriptDir "\NaturalDocs\NaturalDocs") " -r -p .\NDProj" )
}

;-------------------------------------------------------------------------------------------------------------
GetFullPathName(Filename) {
	; Determines the fullpath (absolute path) from relative path
	Size := DllCall("Kernel32.dll\GetFullPathNameW", "Str", Filename, "UInt", 0, "Ptr", 0, "PtrP", 0) 
	VarSetStrCapacity(OutputVar, Size * 2) 
	r := DllCall("Kernel32.dll\GetFullPathNameW", "Str", Filename, "UInt", Size, "Str", OutputVar, "PtrP", 0)
	ret := ""
	if (r > 0)
		ret := RTrim(OutputVar, "\")
	Else
		ret := Filename
	return ret
}