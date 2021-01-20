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

global debug := 0

OutputDebug "DBGVIEWCLEAR" "`n"

WiseGui("Test", "Theme: Warning", "MainText:  WARNING - Unittest running ....", "SubText:  Please be patient! Output is written to OutputDebug")
if (fullTests == 0) {
	dbgOut("!*!*!*!*!*!*!* Development Test mode *!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!`n")
	Yunit.Use(YunitOutputDebug).Test(
		; GDipC.RectCompareTestSuite,
		RectMiscTestSuite
	)
	dbgOut("!*!*!*!*!*!*!* Development Test mode *!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!`n")
} else {
	Yunit.Use(YunitOutputDebug).Test(
		RectCompareTestSuite,
		RectMiscTestSuite
	)
}
WiseGui("Test", "Theme: Info", "MainText:  Unittest finished ....", "SubText:")
sleep(1000)
WiseGui("Test") ; Kill

ExitApp

class RectMiscTestSuite {
	Begin() {
		this.r := GDipC.Rect(100, 101, 108, 109)
	}

	Version() {
		Global ReferenceVersion
		Yunit.assert(this.r.version == ReferenceVersion)
	}

	Constructor() {
		dbgOut(">[" A_ThisFunc "]`n")
		Yunit.assert(this.r.x == 100)
		Yunit.assert(this.r.y == 101)
		Yunit.assert(this.r.width == 108)
		Yunit.assert(this.r.height == 109)
		dbgOut("<[" A_ThisFunc "]`n")
	}

	Getter() {
		dbgOut(">[" A_ThisFunc "]`n")
		Yunit.assert(this.r.xul == this.r.x)
		Yunit.assert(this.r.yul == this.r.y)
		Yunit.assert(this.r.xlr == this.r.x + this.r.width)
		Yunit.assert(this.r.ylr == this.r.y + this.r.height)
		dbgOut("<[" A_ThisFunc "]`n")
	}

	Setter() {
		dbgOut(">[" A_ThisFunc "]`n")
		this.r.xul := 90
		this.r.yul := 80
		this.r.xlr := 210
		this.r.ylr := 220
		Yunit.assert(this.r.x == 90)
		Yunit.assert(this.r.y == 80)
		Yunit.assert(this.r.width == 120)
		Yunit.assert(this.r.height == 140)
		dbgOut("<[" A_ThisFunc "]`n")
	}

	End() {
	}
}

class RectCompareTestSuite {
	Begin() {
		this.r := GDipC.Rect(100, 101, 108, 109)
	}

	Equals() {
		dbgOut(">[" A_ThisFunc "]`n")
		comp := this.r.clone()
		x := this.r.equals(comp)
		Yunit.assert(this.r.equals(comp) == 1)
		Yunit.assert(this.r.equalsLocation(comp) == 1)
		Yunit.assert(this.r.equalsSize(comp) == 1)
		dbgOut("<[" A_ThisFunc "]`n")
		return
	}

	EqualsSize() {
		dbgOut(">[" A_ThisFunc "]`n")
		comp := GDipC.Rect(this.r.x + 10, this.r.y + 10, this.r.width, this.r.height)
		Yunit.assert(this.r.equals(comp) == 0)
		Yunit.assert(this.r.equalsLocation(comp) == 0)
		Yunit.assert(this.r.equalsSize(comp) == 1)
		dbgOut("<[" A_ThisFunc "]`n")
		return
	}

	EqualsLocation() {
		dbgOut(">[" A_ThisFunc "]`n")
		comp := GDipC.Rect(this.r.x, this.r.y, this.r.width + 10, this.r.height + 10)
		Yunit.assert(this.r.equals(comp) == 0)
		x := this.r.equalsLocation(comp)
		Yunit.assert(this.r.equalsLocation(comp) == 1)
		Yunit.assert(this.r.equalsSize(comp) == 0)
		dbgOut("<[" A_ThisFunc "]`n")
		return
	}

	NonEqualsLocation() {
		dbgOut(">[" A_ThisFunc "]`n")
		comp := GDipC.Rect(this.r.x + 10, this.r.y, this.r.width, this.r.height)
		Yunit.assert(this.r.equals(comp) == 0)
		Yunit.assert(this.r.equalsLocation(comp) == 0)
		Yunit.assert(this.r.equalsSize(comp) == 1)
		comp := GDipC.Rect(this.r.x, this.r.y + 10, this.r.width, this.r.height)
		Yunit.assert(this.r.equals(comp) == 0)
		Yunit.assert(this.r.equalsLocation(comp) == 0)
		Yunit.assert(this.r.equalsSize(comp) == 1)
		comp := GDipC.Rect(this.r.x + 10, this.r.y + 10, this.r.width, this.r.height)
		Yunit.assert(this.r.equals(comp) == 0)
		Yunit.assert(this.r.equalsLocation(comp) == 0)
		Yunit.assert(this.r.equalsSize(comp) == 1)
		dbgOut("<[" A_ThisFunc "]`n")
		return
	}

	NonEqualsSize() {
		dbgOut(">[" A_ThisFunc "]`n")
		comp := GDipC.Rect(this.r.x, this.r.y, this.r.width + 10, this.r.height)
		Yunit.assert(this.r.equals(comp) == 0)
		Yunit.assert(this.r.equalsLocation(comp) == 1)
		Yunit.assert(this.r.equalsSize(comp) == 0)
		comp := GDipC.Rect(this.r.x, this.r.y, this.r.width, this.r.height + 10)
		Yunit.assert(this.r.equals(comp) == 0)
		Yunit.assert(this.r.equalsLocation(comp) == 1)
		Yunit.assert(this.r.equalsSize(comp) == 0)
		comp := GDipC.Rect(this.r.x, this.r.y, this.r.width + 10, this.r.height + 10)
		Yunit.assert(this.r.equals(comp) == 0)
		Yunit.assert(this.r.equalsLocation(comp) == 1)
		Yunit.assert(this.r.equalsSize(comp) == 0)
		dbgOut("<[" A_ThisFunc "]`n")
		return
	}

	NonEquals() {
		dbgOut(">[" A_ThisFunc "]`n")
		comp := GDipC.Rect(this.r.x + 1, this.r.y, this.r.width - 1, this.r.height)
		Yunit.assert(this.r.equals(comp) == 0)
		Yunit.assert(this.r.equalsLocation(comp) == 0)
		Yunit.assert(this.r.equalsSize(comp) == 0)
		dbgOut("<[" A_ThisFunc "]`n")
		return
	}

}
/*


class GDipC.RectCompareTestSuite {



	End() {
	}
}

*/