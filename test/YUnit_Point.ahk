#Requires AutoHotkey v2.0-
#Warn
#SingleInstance force

#include "%A_ScriptDir%\..\export.ahk"

#Include "%A_ScriptDir%\..\..\YUnit"
#Include Yunit.ahk
#Include OutputDebug.ahk

#include "%A_ScriptDir%\..\..\dbgout.ahk\export.ahk"
#include "%A_ScriptDir%\..\..\classhelper.ahk\export.ahk"
#include "%A_ScriptDir%\..\..\WiseGUI\WiseGUI.ahk"

ReferenceVersion := "1.0.0"
fullTests := 1

global debug := 1

OutputDebug "DBGVIEWCLEAR" "`n"

WiseGui("Test", "Theme: Warning", "MainText:  WARNING - Unittest running ....", "SubText:  Please be patient! Output is written to OutputDebug")
if (fullTests == 0) {
	dbgOut("!*!*!*!*!*!*!* Development Test mode *!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!`n")
	Yunit.Use(YunitOutputDebug).Test(
		PointCompareTestSuite
	)
	dbgOut("!*!*!*!*!*!*!* Development Test mode *!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!`n")
} else {
	Yunit.Use(YunitOutputDebug).Test(
		PointCompareTestSuite,
		PointMiscTestSuite
	)
}
WiseGui("Test", "Theme: Info", "MainText:  Unittest finished ....", "SubText:")
sleep(1000)
WiseGui("Test") ; Kill

ExitApp

class PointMiscTestSuite
{
	Begin() {
		this.pt := GDipC.Point(100,100)
	}

	Version() {
		Global ReferenceVersion
		Yunit.assert(this.pt._version == ReferenceVersion)
	}

	Constructor() {
		Yunit.assert(this.pt.x == 100)
		Yunit.assert(this.pt.y == 100)
	}

	End() {
	}
}


class PointCompareTestSuite
{
	Begin() {
		this.pt := GDipC.Point(100,100)
	}

	Equal() {
		comp := GDipC.Point(this.pt.x, this.pt.y)
		Yunit.assert(this.pt.equals(comp) == true)
		return
	}

	NonEqual() {
		comp := GDipC.Point(this.pt.x + 10, this.pt.y)
		Yunit.assert(this.pt.equals(comp) == false)
		return
	}

	End() {
	}
}
