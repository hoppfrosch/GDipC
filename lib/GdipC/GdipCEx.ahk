; ####################################################

#include GdipC.ahk
#include JSON.ahk

; ####################################################

/*
Title: GDipCEx 
	
Extensions of several GDipC-Classes
	
Following classes exist:
	
- <GDipCEx.Point> - Handling 2-dimensional points
- <GDipCEx.Rect>  - Handling 2-dimensional rectangles
- <GDipCEx.Size> -  Handling 2-dimensional sizes (width and height)
		
Authors:
<hoppfrosch at hoppfrosch@gmx.de>: Original

About: License
MIT License

Copyright (c) 2020 Johannes Kilian

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), 
to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
class GdipCEx {
; ******************************************************************************************************************************************
/*
Class: GdipCEx
	Extension classes to GDipC as container for several helper classes

Authors:
<hoppfrosch at hoppfrosch@gmx.de>: Original
*/
	_version := "0.1.2"

	__New()  {
	}
		
	__Delete() {
	}

	version[] {
	/* -------------------------------------------------------------------------------
	Property: version [get]
	Version of the class
	
	Remarks:
	* There is no setter available, since this is a constant system property
	*/
		get {
			return this._version
		}
	}

	static toJSON(obj, indent:=0) {
	/* -------------------------------------------------------------------------------
	Method: toJSON()
	Converts Object into JSON

	Example:
	==== AutoHotkey ====
	str := GdipCEx.toJSON(obj, indent := 2)
	===
	*/
		clone := Map()
		for key, value in obj.OwnProps() {
			if (key != "_version")
				clone[key]:=value
		}
		clone["_type"] := type(obj)
		str := Jxon_Dump(clone,indent)

		return str
	}
		
		
; #region ### Includes ##########################################################################################	

; #region ### [C] GDipCEx.Point ############################################################################################	
	class Point extends GDipC.Point	{
	; *********************************************************************************************************************
	/*
	Class: GDipCEx.Point
		2-dimensional point, based on Class <GdipC.Point at https://github.com/AutoHotkey-V2/GdipC>
		Authors:
	<hoppfrosch at hoppfrosch@gmx.de>: Original
	*/

		_version := "0.1.0"
		
		static fromMouse() {
		/* --------------------------------------------------------------------------------------
		Method: fromMouse()
		Creates an new instance from current mouseposition

		Example:

		==== AutoHotkey ====
		pt := GdipCEx.Point.fromMouse()
		===
		*/
			prevCoordMode := A_CoordModeMouse
			CoordMode("Mouse", "Screen")
			MouseGetPos(x, y)
			r := GdipCEx.Point.new(x, y)
			CoordMode("Mouse", prevCoordMode)
			return r
		}
		
		toJSON(indent:=0) {
		/* --------------------------------------------------------------------------------------
		Method: toJSON()
		Converts current Object into JSON

		Example:

		==== AutoHotkey ====
		str := obj.toJSON(indent := 2)
		===
		*/
			str := GdipCEx.toJSON(this,indent)
			return str
		}

		static fromJSON(str) {
		/* --------------------------------------------------------------------------------------
		Method: fromJSON()
		Converts JSON into new Object

		Example:

		==== AutoHotkey ====
		obj := GdipCEx.Point.fromJSON()
		===
		*/
			value := Jxon_Load( str )
			r := GdipCEx.Point.new(value["X"], value["Y"])
			return r
		}

		toOpt() {
		/* --------------------------------------------------------------------------------------
		Method: toOpt()
		Converts current Object into opt string to be used within AHK commands

		Example:

		==== AutoHotkey ====
		str := obj.toOpt()
		===
		*/
			return "x" this.x " y" this.y 
		}

		version[] {
		/* -------------------------------------------------------------------------------
		Property: version [get]
		Version of the class

		Remarks:
		* There is no setter available, since this is a constant system property
		*/
			get {
				return this._version
			}
		}
	}
; #endregion ### [C] GDipCEx.Point #########################################################################################	

; #region ### [C] GDipCEx.Rect ############################################################################################	
	class Rect extends GdipC.Rect {
	; *********************************************************************************************************************
	/*
	Class: GDipCEx.Rect
		2-dimensional rectangle, based on Class <GdipC.Rect>

	Authors:
	<hoppfrosch at hoppfrosch@gmx.de>: Original
	*/

		_version := "0.1.0"

		static fromJSON(str) {
		/* --------------------------------------------------------------------------------------
		Method: fromJSON()
		Converts JSON into new Object

		Example:

		==== AutoHotkey ====
		obj := GdipCEx.Rect.fromJSON()
		===
		*/
			value := Jxon_Load( str )
			r := GdipCEx.Rect.new(value["X"], value["Y"], value.["width"], value["height"])
			return r
		}

		toJSON(indent:=0) {
		/* --------------------------------------------------------------------------------------
		Method: toJSON()
		Converts current Object into JSON

		Example:

		==== AutoHotkey ====
		str := obj.toJSON(indent := 2)
		===
		*/
			str := GdipCEx.toJSON(this,,indent)
			return str
		}

		toOpt() {
		/* --------------------------------------------------------------------------------------
		Method: toOpt()
		Converts current Object into opt string to be used within AHK commands

		Example:

		==== AutoHotkey ====
		str := obj.toOpt()
		===
		*/
			return "x" this.x " y" this.y " w" this.width " h" this.height  
		}
	}
; #endregion ### [C] GDipCEx.Rect #########################################################################################	

; #region ### [C] GDipCEx.Size ############################################################################################	
	class Size extends GdipC.Size {
	; *********************************************************************************************************************
	/*
	Class: GDipCEx.Size
		2-dimensional size, based on Class <GdipC.Size at https://github.com/AutoHotkey-V2/GdipC>

	Authors:
	<hoppfrosch at hoppfrosch@gmx.de>: Original
	*/

		_version := "0.1.0"

		static fromJSON(str) {
		/* --------------------------------------------------------------------------------------
		Method: fromJSON()
		Converts JSON into new Object

		Example:

		==== AutoHotkey ====
		obj := GdipCEx.Rect.fromJSON()
		===
		*/
			value := Jxon_Load( str )
			r := GdipCEx.Rect.new(value["X"], value["Y"], value["width"], value["height"])
			return r
		}

		toJSON(indent:=0) {
		/* --------------------------------------------------------------------------------------
		Method: toJSON()
		Converts current Object into JSON

		Example:

		==== AutoHotkey ====
		str := obj.toJSON(indent := 2)
		===
		*/
			str := GdipCEx.toJSON(this,,indent)
			return str
		}

		toOpt() {
		/* --------------------------------------------------------------------------------------
		Method: toOpt()
		Converts current Object into opt string to be used within AHK commands

		Example:

		==== AutoHotkey ====
		str := obj.toOpt()
		===
		*/
			return "w" this.width " h" this.height  
		}
	}
; #endregion ### [C] GDipCEx.Size #########################################################################################

; #endregion ### Includes #########################################################################################
}