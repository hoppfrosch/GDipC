; ####################################################
/*
Title: GDipC

Implementation of several GDipC-Classes

Following classes exist:

- <GDipC.Color> - Colors
- <GDipC.Point> - Handling 2-dimensional points
- <GDipC.Rect> - Handling 2-dimensional rectangles
- <GDipC.Size> - Handling 2-dimensional sizes (width and height)

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

release_version() {
	return "0.1.0"
}

class GdipC {
; ******************************************************************************************************************************************
/*
Class: GdipC
	Class container for several GDip classes. This class represents the namespace.

Authors:
<hoppfrosch at hoppfrosch@gmx.de>: Original
*/
	_version := "0.1.0"
	__new()  {

		if !DllCall("GetModuleHandle", "str", "gdiplus")
			DllCall("LoadLibrary", "str", "gdiplus")
		si := BufferAlloc(((A_PtrSize = 8) ? 24 : 16, 0), NumPut("uint", 0x1, si))
		DllCall("gdiplus\GdiplusStartup", "uptr*", pToken:=0, "uptr", si, "uint", 0)
		this.pToken := pToken

;		this._New := Gdip.__new
;		Gdip.__new := Gdip.__dummyNew
	}

	__dummyNew() {
		return false
	}

	__delete() {
		this.dispose()
	}

	dispose() {
		DllCall("gdiplus\GdiplusShutdown", "uptr", this.pToken)
		if (hModule := DllCall("GetModuleHandle", "str", "gdiplus"))
			DllCall("FreeLibrary", "uptr", hModule)

;		Gdip.__new := this._New
	}

; ####################################################

class Color {
; *********************************************************************************************************************
/*
Class: GDipC.Color
	GDipC Color - see <https://docs.microsoft.com/de-de/windows/desktop/api/gdipluscolor/nl-gdipluscolor-color>

Authors: 
	<hoppfrosch at hoppfrosch@gmx.de>: Original
*/
	_version := "1.0.0"
	_debug := 1
	
	__new(params*)	{
	/* -------------------------------------------------------------------------------
	Constructor: __new
	
	The constructor supports followings parameters:
	
	1.) Creates a <GDipC.Color> object and initializes it to opaque black.
	==== AutoHotkey ====
	col := GDipC.Color.new()
	===

	2.) Creates a <GDipC.Color> object by using an ARGB value. 
	==== AutoHotkey ====
	col := GDipC.Color.new(ARGB)
	===

	3.) Creates a <GDipC.Color> object by using specified values for the red, green, and blue components. This constructor sets the alpha component to 255 (opaque). 
	==== AutoHotkey ====
	col := GDipC.Color.new(R, G, B)
	===

	4.) Creates a <GDipC.Color> object by using specified values for the alpha, red, green, and blue components. 
	==== AutoHotkey ====
	col := GDipC.Color.new(A, R, G, B)
	===
	*/
		c := params.Length
		if (c = 0){
			this.ARGB := (255 << 24) | (0 << 16) | (0 << 8) | 0
		}
		else  if (c = 1) {
			this.ARGB := params[1]
		}
		else  if (c = 3) {
			this.ARGB := (255 << 24) | (params[1] << 16) | (params[2] << 8) | params[3]
		}
		else  if (c = 4) {
			this.ARGB := (params[1] << 24) | (params[2] << 16) | (params[3] << 8) | params[4]
		}
		else {
			throw "Incorrect number of parameters for "  A_ThisFunc
		}
	}
	; ===== Properties ===============================================================
	a[] {
	/* -------------------------------------------------------------------------------
	Property: a [get/set]
	gets/sets the alpha component of this Color object.
	
	Value:
	a - alpha component
	*/
		get {
			return (0xff000000 & this.ARGB) >> 24
		}
		set {
			this.ARGB := (value << 24) | (this.r << 16) | (this.g << 8) | this.b
			return value
		}
	}
	alpha[] {
	/* -------------------------------------------------------------------------------
	Property: alpha [get/set]
	gets/sets the alpha component of this Color object.
	
	Value:
	a - alpha component
	*/
		get {
			return this.a
		}
		set {
			this.a := value
			return value
		}
	}
	r[] {
	/* -------------------------------------------------------------------------------
	Property: r [get/set]
	gets/sets the red component of this Color object.
	
	Value:
	r - red component
	*/
		get {
			return (0x00ff0000 & this.ARGB) >> 16
		}
		set {
			this.ARGB := (this.a << 24) | (value << 16) | (this.g << 8) | this.b
			return value
		}
	}
	g[] {
	/* -------------------------------------------------------------------------------
	Property: g [get/set]
	gets/sets the green component of this Color object.
	
	Value:
	g - green component
	*/
		get {
			return (0x0000ff00 & this.ARGB) >> 8
		}
		set {
			this.ARGB := (this.a << 24) | (this.r << 16) | (value << 8) | this.b
			return value
		}
	}
	b[] {
	/* -------------------------------------------------------------------------------
	Property: b [get/set]
	gets/sets the blue component of this Color object.
	
	Value:
	b - blue component
	*/
		get {
			return 0x000000ff & this.ARGB
		}
		set {
			this.ARGB := (this.a << 24) | (this.r << 16) | (this.g << 8) | value
			return value
		}
	}
	RGB[] {
	/* ------------------------------------------------------------------------------- 
	Property: hexRGB [get]
	Get hex-color value for r,g,b components
	*/
		get {
			return format("0x{1:02x}{2:02x}{3:02x}", this.r, this.g, this.b)
		}
		set {
			this.r := ((value & 0xFF0000) >> 16)
			this.g := ((value & 0x00FF00) >> 8)
			this.b  :=  (value & 0x0000FF)
			return value
		}
	}
	hex[] {
	/* ------------------------------------------------------------------------------- 
	Property: hex [get]
	Get hex-color value
	*/
		get {
			return format("0x{1:02x}{2:02x}{3:02x}{4:02x}", this.a, this.r, this.g, this.b)
		}
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
	
; ####################################################
	
class Size {
; *********************************************************************************************************************
/*
Class: GDipC.Size
	GDipC Size - see <https://msdn.microsoft.com/en-us/library/windows/desktop/ms534504(v=vs.85).aspx>

Authors: 
	<hoppfrosch at hoppfrosch@gmx.de>: Original
*/
	_version := "1.0.0"
	Width := 0
	Height := 0
	
	__new(params*)	{
	/* -------------------------------------------------------------------------------
	Constructor: __new
	
	The constructor supports followings parameters:
	
	1.) Creates a <GDipC.Size> object and initializes the Width and Height data members to zero.
	==== AutoHotkey ====
	sz := GDipC.Size.new()
	===

	2.) Creates a <GDipC.Size> object using two integers to initialize the Width and Height data members. 
	==== AutoHotkey ====
	sz := GDipC.Size.new(Width, Height)
	===

	3.) Creates a <GDipC.Size> objectand copies the data members from another Size object. 
	==== AutoHotkey ====
	sz := GDipC.Size.new(sz1)
	===
	*/
		c := params.Length
		if (c = 0) {
			this.Width := 0
			this.Height := 0
		}
		else  if (c = 1) {
			if (params[1].__Class == "GdipC.Size") {
				this.Width := params[1].Width
				this.Height := params[1].Height
			}
			else { 
				throw "Incorrect parameter type for " A_ThisFunc
			}
		}
		else  if (c = 2) {
			this.Width := params[1]
			this.Height := params[2]
		}
		else {
			throw "Incorrect number of parameters for "  A_ThisFunc
		}
	}
	empty() {
	/* --------------------------------------------------------------------------------------
	Method: empty()
	determines whether a <GDipC.Size> object is empty (i.e size is zero) 
	Example:

	==== AutoHotkey ====
	isEmpty := pt1.empty()
	===
	*/
		return ((this.Width ==0) && (this.Height == 0))
	}
	equals(params*) {
	/* --------------------------------------------------------------------------------------
	Method: equals()
	determines whether two <GDipc.Size> objects are equal. Two Sizes are considered equal if they have the same Width and Height data members. 

	Example:

	==== AutoHotkey ====
	eq := sz1.equals(sz2)
	===
	*/
		c := params.Length
		if (c = 1) {
			if (params[1].__Class == "GdipC.Size") {
				return ((this.Width == params[1].Width) && (this.Height == params[1].Height))
			}
			else { 
				throw "Incorrect parameter type for " A_ThisFunc
			}
		}
		else {
			throw "Incorrect number of parameters for "  A_ThisFunc
		}
	}

	; The original implementation overloads several operators
	; As this is not possible with AHK, a separate function is offered
	
	subtract(params*) {
	/* --------------------------------------------------------------------------------------
	Method: subtract()
	subtracts the Width and Height data members of two <GDipC.Size> objects. 

	Example:
	==== AutoHotkey ====
	sz3 := sz1.subtract(sz2)
	; i.e. (sz3.width, sz3.height) = (sz1.width - sz2.width, sz1.height - sz2.height)
	===
	*/
		; Alternative to overloaded minus-operator ("-")
		c := params.Length
		if (c = 2) {
			return GdipC.Size.new((this.Width - params[1]),(this.Height - params[2]))
		}
		if (c = 1) {
			if (params[1].__Class == "GdipC.Size") {
				return GdipC.Point.new((this.Width - params[1].Width),(this.Height - params[1].Height))
			}
			else { 
				throw "Incorrect parameter class for " A_ThisFunc
			}
		}
		else {
			throw "Incorrect number of parameters for "  A_ThisFunc
		}
	}
	add(params*) {
	/* --------------------------------------------------------------------------------------
	Method: add()
	adds the Width and Height data members of two <GDipC.Size> objects. 

	Example:
	==== AutoHotkey ====
	sz3 := sz1.add(sz2)
	; i.e. (sz3.width, sz3.height) = (sz1.width + sz2.width, sz1.height + sz2.height)
	===
	*/
		; Alternative to overloaded plus-operator ("+")
		c := params.Length
		if (c = 2) {
			return GdipC.Size((this.Width + params[1]),(this.Height + params[2]))
		}
		if (c = 1) {
			if (params[1].__Class == "GdipC.Size") {
				return GdipC.Point.new((this.Width + params[1].Width),(this.Height + params[1].Height))
			}
			else { 
				throw "Incorrect parameter class for " A_ThisFunc
			}
		}
		else {
			throw "Incorrect number of parameters for "  A_ThisFunc
		}
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
	
; ####################################################
	
class Point {
; *********************************************************************************************************************
/*
Class: GDipC.Point
	GDipC Point - see <https://msdn.microsoft.com/en-us/library/windows/desktop/ms534487(v=vs.85).aspx>

Authors: 
	<hoppfrosch at hoppfrosch@gmx.de>: Original
*/
	_version := "1.0.0"
	X := 0
	Y := 0
	
	__new(params*) {
	/* -------------------------------------------------------------------------------
	Constructor: __new
	
	The constructor supports followings parameters:
	
	1.) Creates a <GDipC.Point> object and initializes the X and Y data members to zero.
	==== AutoHotkey ====
	pt := GDipC.Point.new()
	===

	2.) Creates a <GDipC.Point> object using two integers to initialize the X and Y data members. 
	==== AutoHotkey ====
	pt := GDipC.Point.new(X, Y)
	===

	3.) Creates a <GDipC.Point> objectand copies the data members from another Point object. 
	==== AutoHotkey ====
	pt := GDipC.Point.new(pt1)
	===

	4.) Creates a <GDipC.Point> object and using a <GDipC.Size> object to initialize the X and Y data members. 
	==== AutoHotkey ====
	sz := GDipC.Size.new(100,110)
	pt := GDipC.Point.new(sz)
	===
	*/
		c := params.Length
		if (c = 0) {
			this.X := 0
			this.Y := 0
		}
		else  if (c = 1) {
			if (params[1].__Class == "GdipC.Point") {
				this.X := params[1].X
				this.Y := params[1].Y
			}
			else if (params[1].__Class == "GdipC.Size") {
				this.X := params[1].Width
				this.Y := params[1].Height
			}
			else { 
				throw "Incorrect parameter class for " A_ThisFunc
			}
		}
		else  if (c = 2) {
			this.X := params[1]
			this.Y := params[2]
		}
		else {
			throw "Incorrect number of parameters for "  A_ThisFunc
		}
	}
	
	equals(sz) {
	/* --------------------------------------------------------------------------------------
	Method: equals()
	determines whether two <GDipc.Point> objects are equal. Two points are considered equal if they have the same X and Y data members. 

	Example:
	==== AutoHotkey ====
	eq := pt1.equals(pt2)
	===
	*/
		if (sz.__Class == "GdipC.Point") {
			return ((this.X == sz.X) && (this.X == sz.X))
		}
		else { 
			throw "Incorrect parameter class for " A_ThisFunc
		}
	}
	
	; The original implementation overloads several operators
	; As this is not possible with AHK, a separate function is offered
	
	subtract(params*) {
	/* --------------------------------------------------------------------------------------
	Method: subtract()
	subtracts the X and Y data members of two <GDipC.Point> objects. 

	Example:
	==== AutoHotkey ====
	pt3 := pt1.subtract(pt2)
	; i.e. (pt3.x, pt3.y) = (pt1.x - pt2.x, pt1.y - pt2.y)
	===
	*/
		; Alternative to overloaded minus-operator ("-")
		c := params.Length
		if (c = 2) {
			return GDipC.Point.new((this.X - params[1]),(this.Y - params[2]))
		}
		if (c = 1) {
			if (params[1].__Class == "GdipC.Point") {
				return GDipC.Point.new((this.X - params[1].X),(this.Y - params[1].X))
			}
			else if (params[1].__Class == "GdipC.Size") {
				return GDipC.Point.new((this.X - params[1].Width),(this.Y - params[1].Height))
			}
			else { 
				throw "Incorrect parameter class for " A_ThisFunc
			}
		}
		else {
			throw "Incorrect number of parameters for "  A_ThisFunc
		}
	}
	add(params*) {
	/* --------------------------------------------------------------------------------------
	Method: add()
	adds the X and Y data members of two <GDipC.Point> objects. 

	Example:
	==== AutoHotkey ====
	pt3 := pt1.add(pt2)
	; i.e. (pt3.x, pt3.y) = (pt1.x + pt2.x, pt1.y + pt2.y)
	===
	*/
		; Alternative to overloaded minus-operator ("-")
		c := params.Length
		if (c = 2) {
			return GDipC.Point.new((this.X + params[1]),(this.Y + params[2]))
		}
		if (c = 1) {
			if (params[1].__Class == "GdipC.Point") {
				return GDipC.Point.new((this.X + params[1].X),(this.Y + params[1].X))
			}
			else if (params[1].__Class == "GdipC.Size") {
				return GDipC.Point.new((this.X + params[1].Width),(this.Y + params[1].Height))
			}
			else { 
				throw "Incorrect parameter class for " A_ThisFunc
			}
		}
		else {
			throw "Incorrect number of parameters for "  A_ThisFunc
		}
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
	
; ####################################################
	
class Rect {
; *********************************************************************************************************************
/*
Class: GDipC.Rect
	GDipC Rect - see <https://msdn.microsoft.com/en-us/library/windows/desktop/ms534495(v=vs.85).aspx>

Authors: 
	<hoppfrosch at hoppfrosch@gmx.de>: Original
*/
	_version := "1.0.0"
	
	__new(params*) {
	/* -------------------------------------------------------------------------------
	Constructor: __new
	
	The constructor supports followings parameters:
	
	1.) Creates a <GDipC.Rect> object whose x-coordinate, y-coordinate, width, and height are all zero.
	==== AutoHotkey ====
	rect := GDipC.Rect.new()
	===

	2.) Creates a <GDipC.Rect> object by using four integers to initialize the X, Y, Width, and Height data members.  
	==== AutoHotkey ====
	rect := GDipC.Rect.new(X, Y, Width, Height)
	===

	3.) Creates a <GDipC.Rect> objectby using a <GDipC.Point> object to initialize the X and Y data members and a <GDipC.Sizr> object to initialize the Width and Height data members. 
	==== AutoHotkey ====
	pt := GDipC.Point.new(10, 20)
	sz := GDipC.Size.new(100, 200)
	rect := GDipC.Rect.new(pt, sz)
	===
	*/
		c := params.Length
		if (c = 0) {
			this.x := 0
			this.y := 0
			this.Width := 0
			this.Height := 0
		}
		else if (c = 4)
		{
			this.x := params[1]
			this.y := params[2]
			this.width := params[3]
			this.height := params[4]
		}
		else if (c = 2)
		{
			if ((params[1].__Class == "GdipC.Point") && (params[2].__Class == "GdipC.Size")) {
				this.x := params[1].x
				this.y := params[1].y
				this.width := params[2].width
				this.height := params[2].height
			}
			Else
				throw "Wrong parameter types for "  A_ThisFunc
		}
		else
			throw "Incorrect number of parameters for "  A_ThisFunc
		
	}
	clone() {
	/* --------------------------------------------------------------------------------------
	Method: clone()
	creates a new <GDipC.Rect> object and initializes it with the contents of this Rect object. 

	Example:
	==== AutoHotkey ====
	rect2 := rect1.clone()
	===
	*/
		r := GDipC.Rect.new(this.x, this.y, this.width, this.height)
		return r
	}
	contains(params*) {
	/* --------------------------------------------------------------------------------------
	Method: contains()
	The method <GDipC.Rect.contains> checks whether anther object is within the given rectangle. Following overloaded methods are supported:
	
	1.) determines whether the <GDipC.Point> is inside this rectangle. 
	==== AutoHotkey ====
	rect := GDipC.Rect.new(0, 0, 50, 50)
	pt := GDipC.Point.new(10, 20)
	contains := rect.contains(pt)
	===

	2.) determines whether the point (x,y) is inside this rectangle. 
	==== AutoHotkey ====
	rect := GDipC.Rect.new(0, 0, 50, 50)
	contains := rect.contains(10,20)
	===

	3.) determines whether another <GDipC.Rect> is inside this rectangle. 
	==== AutoHotkey ====
	rect1 := GDipC.Rect.new(0, 0, 50, 50)
	rect2 := GDipC.Rect.new(10, 10, 20, 20)
	contains := rect1.contains(rect2)
	===
	*/
		c := params.Length
		if (c = 1) {
			if (params[1].__Class == "GdipC.Point") {
				return this.contains(params[1].x, params[1].y)
			}
			if (params[1].__Class == "GdipC.Rect") {
				x := params[1].x
				y := params[1].y
				width := params[1].width
				height := params[1].height
				if ((x >= this.x) && ((x + width) <= (this.x + this.width)) && (y >= this.y) && ((y + height) <= (this.y + this.height))) {
					return true
				}
			}
			else
				throw "Incorrect parameter type for " A_ThisFunc
		} else if (c = 2) {
			x := params[1]
			y := params[2]
			if ((x >= this.x) && (x <= (this.x + this.width)) && (y >= this.y) && (y <= (this.y + this.width))) {
				return true
			}
		}
		else
			throw "Incorrect number of parameters for "  A_ThisFunc
		return false
	}
	equals(params*) {
	/* --------------------------------------------------------------------------------------
	Method: equals()
	determines whether two rectangles are the same.

	Example:
	==== AutoHotkey ====
	equal := rect1.equals(rect2)
	===
	*/
		c := params.Length
		if (c = 1) {
			if (params[1].__Class == "GdipC.Rect") {
				if ((params[1].x == this.x) && (params[1].y == this.y) && (params[1].width == this.width) && (params[1].height == this.height)) {
					return true
				}
			}
			else
				throw "Incorrect parameter type for " A_ThisFunc
		}
		else
			throw "Incorrect number of parameters for "  A_ThisFunc
		return false
	}
	getBottom() {
	/* --------------------------------------------------------------------------------------
	Method: getBottom()
	gets the y-coordinate of the bottom edge of the rectangle. 
	
	Example:
	==== AutoHotkey ====
	bot := rect.getBottom()
	===
	*/
		return (this.y + this.height)
	}
	getBounds() {
	/* --------------------------------------------------------------------------------------
	Method: getBounds()
	makes a copy of this rectangle. 
	
	Example:
	==== AutoHotkey ====
	bounds := rect.getBounds()
	===
	*/
		return this.clone()
	}
	getLeft() {
	/* --------------------------------------------------------------------------------------
	Method: getLeft()
	gets the x-coordinate of the left edge of the rectangle.
	
	Example:
	==== AutoHotkey ====
	lft := rect.getLeft()
	===
	*/
		return (this.x)
	}
	getLocation() {
	/* --------------------------------------------------------------------------------------
	Method: getLocation()
	gets the coordinates of the upper-left corner of the rectangle as a <GDip.Point> object. 
	
	Example:
	==== AutoHotkey ====
	pt := rect.getLocation()
	===
	*/
		pt := GDipC.Point.new(this.x, this.y)
		return pt
	}
	getRight() {
	/* --------------------------------------------------------------------------------------
	Method: getRight()
	gets the x-coordinate of the right edge of the rectangle.
	
	Example:
	==== AutoHotkey ====
	lft := rect.getRight()
	===
	*/
		return (this.x + this.width)
	}
	getSize() {
	/* --------------------------------------------------------------------------------------
	Method: getSize()
	gets the width and height of the rectangle as an <GDip.Size> object. 
	
	Example:
	==== AutoHotkey ====
	pt := rect.getSize()
	===
	*/
		sz := GDipC.Size.new(this.width, this.height)
		return sz
	}
	getTop() {
	/* --------------------------------------------------------------------------------------
	Method: getTop()
	gets the y-coordinate of the top edge of the rectangle. 
	
	Example:
	==== AutoHotkey ====
	bot := rect.getTop()
	===
	*/
		return (this.y)
	}
	inflate(params*) {
	/* --------------------------------------------------------------------------------------
	Method: inflate()
	expands the rectangle. Following overloaded methods are supported:
	
	1.) expands the rectangle by dx on the left and right edges, and by dy on the top and bottom edges. 
	==== AutoHotkey ====
	rect := GDipC.Rect.new(0, 0, 50, 50)
	rect.inflate(10,20)
	===

	2.) expands the rectangle by the value of <GDipC.Point> X on the left and right edges, and by the value of <GDipC.Point> Y on the top and bottom edges. 
	==== AutoHotkey ====
	rect := GDipC.Rect.new(0, 0, 50, 50)
	pt := GDipC.Point.new(10, 20)
	rect.inflate(pt)
	===
	*/
		c := params.Length
		if (c = 1) {
			if (params[1].__Class == "GdipC.Point") {
				this.inflate(params[1].x, params[1].y)
			}
			else
				throw "Wrong parameter types for "  A_ThisFunc
		}
		else if (c = 2) {
			this.x := this.x - params[1]
			this.y := this.y - params[2]
			this.width := this.width + 2*params[1]
			this.height := this.height + 2*params[2]
		}
		else
			throw "Incorrect number of parameters for "  A_ThisFunc
		return false
	}
	intersect(params *) {
	/* --------------------------------------------------------------------------------------
	Method: intersect()
	replaces this rectangle with the intersection of another object. Following overloaded methods are supported:
	
	1.) replaces this rectangle with the intersection of itself and another <GDipC.Rect>. 
	==== AutoHotkey ====
	rect1 := GDipC.Rect.new(0, 0, 50, 50)
	rect2 := GDipC.Rect.new(10, 10, 50, 50)
	isIntersected := rect1.intersects(rect2)
	===
	*/
		c := params.Length
		if (c = 1) {
			if (params[1].__Class == "GdipC.Rect") {
				right := (this.getRight() < params[1].getRight())?this.getRight():params[1].getRight()
				left := (this.getLeft() > params[1].getLeft())?this.getLeft():params[1].getLeft()
				bottom := (this.getBottom() < params[1].getBottom())?this.getBottom():params[1].getBottom()
				top := (this.getTop() > params[1].getTop())?this.getTop():params[1].getTop()
				ret := GDipC.Rect.new(left, top, right-left, bottom-top)
				bIntersects := !ret.isEmptyArea()
				if (!bIntersects) {
					; if they don't intersect the result is an null-sized rectangle
					ret := GDipC.Rect.new()
				}
				this.x := ret.x
				this.y := ret.y
				this.width := ret.width
				this.height := ret.height
				return (bIntersects)
			}
			else
				throw "Wrong parameter types for "  A_ThisFunc
		}
		else
			throw "Incorrect number of parameters for "  A_ThisFunc
		return false
	}
	intersectsWith(params *) {
	/* --------------------------------------------------------------------------------------
	Method: intersectsWith()
	determines whether this rectangle intersects another rectangle. 
	
	Example:
	==== AutoHotkey ====
	rect1 := GDipC.Rect.new(0, 0, 50, 50)
	rect2 := GDipC.Rect.new(10, 10, 50, 50)
	isIntersected := rect1.intersectsWith(rect2)
	===
	*/
		c := params.Length
		if (c = 1) {
			if (params[1].__Class == "GdipC.Rect") {
				return  ((this.GetLeft() < params[1].GetRight()) && (this.GetTop() < params[1].GetBottom()) && (this.GetRight() > params[1].GetLeft()) && (this.GetBottom() > params[1].GetTop()))
			}
			else
				throw "Wrong parameter types for "  A_ThisFunc
		}
		return false
	}
	isEmptyArea() {
	/* --------------------------------------------------------------------------------------
	Method: isEmptyArea()
	determines whether this rectangle is empty.
	
	Example:
	==== AutoHotkey ====
	rect := GDipC.Rect.new(10, 20, 0, 0)
	isEmpty := rect.isEmptyArea(rect2)
	===
	*/
		return (this.width <= 0) || (this.height <= 0)
	}
	offset(params*) {
	/* --------------------------------------------------------------------------------------
	Method: offset()
	moves the rectangle. Following overloaded methods are supported:
	
	1.) moves the rectangle by dx horizontally and by dy vertically.  
	==== AutoHotkey ====
	rect := GDipC.Rect.new(0, 0, 50, 50)
	rect.offset(10,20)
	===

	2.) moves this rectangle horizontally a distance of <GDipC.Point> X and vertically a distance of <GDipC.Point> Y.
	==== AutoHotkey ====
	rect := GDipC.Rect.new(0, 0, 50, 50)
	pt := GDipC.Point.new(10, 20)
	rect.offset(pt)
	===
	*/	
		c := params.Length
		if (c = 1) {
			if (params[1].__Class == "GdipC.Point") {
				this.offset(params[1].x, params[1].y)
			}
			else
				throw "Wrong parameter types for "  A_ThisFunc
		}
		else if (c = 2) {
			this.x := this.x + params[1]
			this.y := this.y + params[2]
		}
		else
			throw "Incorrect number of parameters for "  A_ThisFunc
		return
	}
	union(params *) {
	/* --------------------------------------------------------------------------------------
	Method: union()
	determines the union of two rectangles and stores the result in a >GDipC.Rect> object. 
	
	Example:
	==== AutoHotkey ====
	rect1 := GDipC.Rect.new(10, 20, 100, 100)
	rect2 := GDipC.Rect.new(20, 30, 200, 2000)
	rect3 := rect1.union(rect2)
	===
	*/
		c := params.Length
		if (c = 1) {
			if (params[1].__Class == "GdipC.Rect") {
				right := (this.getRight() > params[1].getRight())?this.getRight():params[1].getRight()
				left := (this.getLeft() < params[1].getLeft())?this.getLeft():params[1].getLeft()
				bottom := (this.getBottom() > params[1].getBottom())?this.getBottom():params[1].getBottom()
				top := (this.getTop() < params[1].getTop())?this.getTop():params[1].getTop()
				this.x := left
				this.y := top
				this.width := right-left
				this.height := bottom-top
				return (!this.isEmptyArea())
			}
			else
				throw "Wrong parameter types for "  A_ThisFunc
		}
		else
			throw "Incorrect number of parameters for "  A_ThisFunc
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
	
; ####################################################
}