; ####################################################
/*
Title: GDipC

Implementation of GDI+ Classes; see <https://docs.microsoft.com/en-us/windows/win32/gdiplus/-gdiplus-class-classes>


Main class, not existent in GdipC:

- <GDipC.Obj> - Fundamental graphics panel

Following classes are implemented:

- <GDipC.Color> - Colors
- <GDipC.Point> - Handling 2-dimensional points
- <GDipC.Rect> - Handling 2-dimensional rectangles
- <GDipC.Size> - Handling 2-dimensional sizes (width and height)

Following classes are only partly implemented:

- <GDipC.Bitmap> - creating and manipulating raster images.
- <GDipC.Graphics> - methods for drawing lines, curves, figures, images, and text.
- <GDipC.Pen> - object used to draw lines and curves.

Following classes are not yet implemented:

- <GDipC.AdjustableArrowCap>
- <GDipC.BitmapData>
- <GDipC.Blur>
- <GDipC.BrightnessContrast>
- <GDipC.Brush>
- <GDipC.CachedBitmap>
- <GDipC.CharacterRange>
- <GDipC.ColorBalance>
- <GDipC.ColorCurve>
- <GDipC.ColorLUT>
- <GDipC.ColorMatrixEffect>
- <GDipC.CustomLineCap>
- <GDipC.Effect>
- <GDipC.EncoderParameter>
- <GDipC.EncoderParameters>
- <GDipC.Font>
- <GDipC.FontCollection>
- <GDipC.FontFamily>
- <GDipC.GdiplusBase>
- <GDipC.GraphicsPath>
- <GDipC.GraphicsPathIterator>
- <GDipC.HatchBrush>
- <GDipC.HueSaturationLightness>
- <GDipC.Image>
- <GDipC.ImageAttributes>
- <GDipC.ImageCodecInfo>
- <GDipC.ImageItemData>
- <GDipC.InstalledFontCollection>
- <GDipC.Levels>
- <GDipC.LinearGradientBrush>
- <GDipC.Matrix>
- <GDipC.Metafile>
- <GDipC.MetafileHeader>
- <GDipC.PathData>
- <GDipC.PathGradientBrush>
- <GDipC.PointF>
- <GDipC.PrivateFontCollection>
- <GDipC.PropertyItem>
- <GDipC.RectF>
- <GDipC.RedEyeCorrection>
- <GDipC.Region>
- <GDipC.Sharpen>
- <GDipC.SizeF>
- <GDipC.SolidBrush>
- <GDipC.StringFormat>
- <GDipC.TextureBrush>
- <GDipC.Tint>

Authors:
<hoppfrosch at hoppfrosch@gmx.de>: Original

About: License
MIT License

Copyright (c) 2020-2021 Johannes Kilian

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

class GdipC {
; ******************************************************************************************************************************************
/* Class: GdipC
	Class container for several GDip classes. This class represents the namespace.

Authors:
<hoppfrosch at hoppfrosch@gmx.de>: Original
*/
	version := "1.0.0"
	Static token     := 0

	__new()  {

		if !DllCall("GetModuleHandle", "str", "gdiplus")
			DllCall("LoadLibrary", "str", "gdiplus", "UPtr")

        si := Buffer((A_PtrSize=8)?24:16,0), NumPut("UInt", 1, si)
        r2 := DllCall("gdiplus\GdiplusStartup", "UPtr*", &pToken:=0, "UPtr", si.ptr, "UPtr", 0) ; success = 0

		this.token := pToken
	}

	__delete() {
		this.dispose()
	}

	dispose() {
		If (this.token != 0) {
			DllCall("gdiplus\GdiplusShutdown", "uptr", this.token)
			this.token := 0
		}
		if (hModule := DllCall("GetModuleHandle", "str", "gdiplus")) {
			DllCall("FreeLibrary", "uptr", hModule)
		}
	}

; ####################################################
class Obj {
; *********************************************************************************************************************
/* Class: GDipC.Obj
	GDipC Grapicspanel

Authors:
	<hoppfrosch at hoppfrosch@gmx.de>: Original
*/
	__new(params*)	{
	/* -------------------------------------------------------------------------------
	Constructor: __new

	The constructor supports followings parameters:

	2.) Creates a <GDipC.Obj> object and using a <GDipC.Size> object to initialize the size member and a graphics panel is initialized
	==== AutoHotkey ====
	sz := GDipC.Size(100,110)
	obj := GDipC.Obj(sz)
	===

	3.) Creates a <GDipC.Obj> object and using a <GDipC.Size> object to initialize the object as graphics panel.
	==== AutoHotkey ====
	bm := GDipC.Bitmap(300,300)
	obj := GDipC.Obj(bm)
	===

	4.) Creates a <GDipC.Obj> object and using width and height to initialize the size member. A graphics panel is initialized
	==== AutoHotkey ====
	obj := GDipC.Obj(s100,100)
	===

	*/
		c := params.Length
		if (c = 0) {
			this.size := GDipC.Size(0,0)
		}
		else  if (c = 1) {
			if (params[1].__Class == "GdipC.Size") {
				this.size := params[1]
				hasGraphics := false
			}
			/* TODO: Construct from GdipC.Bitmap
			if (params[1].__Class == "GdipC.Bitmap") {
				bitmap1 := params[1]
				this.size := bitmap1.size
				this.pGraphics := bitmap1.GraphicsFromImage(bitmap1.Pointer)
				hasGraphics := true
			}
			*/
			else {
				throw "Incorrect parameter class for " A_ThisFunc
			}
		}
		else  if (c = 2) {
			this.size := GdipC.Size(params[1], params[2])
			hasGraphics := false
		}
		else {
			throw "Incorrect number of parameters for "  A_ThisFunc
		}

		if (!hasGraphics) {
			; TODO: this.hBitmap := this.CreateDIBSection(this.size.width, this.size.height)
			; TODO: this.hdc := this.CreateCompatibleDC()
			; TODO:this.hgdiObj := this.SelectObject(this.hdc, this.hBitmap)
			; TODO: this.pGraphics := this.GraphicsFromHDC(this.hdc)
		}
		; TODO: this.SetSmoothingMode(this.pGraphics, 4)
		; TODO: this.SetInterpolationMode(this.pGraphics, 7)
	}

	__delete() {
		this.dispose()
	}

	dispose() {
	/* --------------------------------------------------------------------------------------
	Method: dispose()
	Deletes the graphics panel
	*/
		this.SelectObject(this.hdc, this.hgdiObj)
		; TODO: this.DeleteObject(this.hBitmap)
		this.DeleteDC(this.hdc)
		; TODO: this.DeleteGraphics(this.pGraphics)
		this.hdc := ""
		this.hgdiObj := ""
		this.hBitmap := ""
		this.pGraphics := ""
	}

	DeleteDC(hdc) {
	/* --------------------------------------------------------------------------------------
	Method: DeleteDC()
	This function deletes the specified device context (DC).

	Parameters:
	hdc - A handle to the device context.

	Returns:
	If the function succeeds, the return value is nonzero. Else zero in case of failure
	*/
		return DllCall("DeleteDC", "uptr", hdc)
	}

	GetDC(hwnd:=0) {
	/* --------------------------------------------------------------------------------------
	Method: GetDC()
	This method retrieves a handle to a display device context (DC) for the client area of the specified window.
	The display device context can be used in subsequent graphics display interface (GDI) functions to draw in the client area of the window.

	Parameters:
	hwnd - Handle to the window whose device context is to be retrieved. If this value is NULL, GetDC retrieves the device context for the entire screen

	Returns:
	hdc - The handle the device context for the specified window's client area indicates success. NULL indicates failure
	*/
		Ptr := "UPtr"
		return DllCall("GetDC", Ptr, hwnd)
	}

	GetDCEx(hwnd, flags:=0, hrgnClip:=0) {
	/* --------------------------------------------------------------------------------------
	Method: GetDCEx()
	This nethod is an extension to the <GdipC.Obj.GetDC> function, which gives an application more control over how and whether clipping occurs in the client area.

	Parameters:
	hwnd - Handle to the window whose device context is to be retrieved. If this value is NULL, GetDC retrieves the device context for the entire screen
	flags - Specifies how the device context is created. See <description here at https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getdcex>
	hrgnClip - Specifies a clipping region that may be combined with the visible region of the device context.

	Returns:
	hdc - The handle the device context for the specified window's client area indicates success. NULL indicates failure
	*/
		return DllCall("GetDCEx", "uptr", hwnd, "uptr", hrgnClip, "int", flags)
	}

	ReleaseDC(hdc, hwnd:=0) 	{
	/* --------------------------------------------------------------------------------------
	Method: ReleaseDC()
	This function  releases a device context (DC), freeing it for use by other applications.
	The effect of the ReleaseDC function depends on the type of DC. It frees only common and window DCs. It has no effect on class or private DCs.

	Parameters:
	hdc - A handle to the DC to be released.
	hwnd - A handle to the window whose DC is to be released.

	Returns:
	The return value indicates whether the DC was released. If the DC was released, the return value is 1.
	If the DC was not released, the return value is zero.
	*/
		return DllCall("ReleaseDC", "uptr", hwnd, "uptr", hdc)
	}

	SelectObject(hdc, hgdiObj) {
	/* --------------------------------------------------------------------------------------
	Method: SelectObject()
	This function  rselects an object into the specified device context (DC). The new object
	replaces the previous object of the same type.

	Parameters:
	hdc - A handle to the DC.
	h - A handle to the object to be selected. The specified object must have been created by
	using specific functions.

	Returns:
	If the selected object is not a region and the function succeeds, the return value is a handle
	to the object being replaced. If the selected object is a region and the function succeeds,
	the return value is one of the following values:
	SIMPLEREGION -	Region consists of a single rectangle.
	COMPLEXREGION -	Region consists of more than one rectangle.
	NULLREGION	- Region is empty.
	*/
		return DllCall("SelectObject", "uptr", hdc, "uptr", hgdiObj)
	}

	SetSmoothingMode(pGraphics, smoothingMode) {
	/* --------------------------------------------------------------------------------------
	Method: SetSmoothingMode()
	This function  releases a device context (DC), freeing it for use by other applications.
	The effect of the ReleaseDC function depends on the type of DC. It frees only common and window DCs. It has no effect on class or private DCs.

	Parameters:
	pGraphics - A handle to the DC to be released.
	smoothingMode - A handle to the window whose DC is to be released.

	Returns:
	The return value indicates whether the DC was released. If the DC was released, the return value is 1.
	If the DC was not released, the return value is zero.
	*/
		return DllCall("gdiplus\GdipSetSmoothingMode", "uptr", pGraphics, "int", smoothingMode)
	}
}

; ####################################################
class Bitmap { ; TODO: Implementation of Bitmap
	; *********************************************************************************************************************
	/* Class: GDipC.Bitmap
		GDipC Bitmap - see <https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nl-gdiplusheaders-bitmap>

		The Bitmap class inherits from the Image class. The Image class provides methods for loading and saving vector images
		(metafiles) and raster images (bitmaps). The Bitmap class expands on the capabilities of the Image class by providing
		additional methods for creating and manipulating raster images.

	Authors:
		<hoppfrosch at hoppfrosch@gmx.de>: Original

	Not Yet implemented:

	- Bitmap.ApplyEffect - creates a new Bitmap object by applying a specified effect to an existing Bitmap object.
	- Bitmap.Bitmap - Creates a <GDipC.Bitmap> object
	- Bitmap.Clone - creates a new Bitmap object by copying a portion of this bitmap.
	- Bitmap.ConvertFormat - converts a bitmap to a specified pixel format. The original pixel data in the bitmap is replaced by the new pixel data.
	- Bitmap.FromBITMAPINFO - creates a Bitmap object based on a BITMAPINFO structure and an array of pixel data.
	- Bitmap.FromDirectDrawSurface7 - creates a Bitmap object based on a DirectDraw surface. The Bitmap object maintains a reference to the DirectDraw surface until the Bitmap object is deleted.
	- Bitmap.FromFile - creates a Bitmap object based on an image file.
	- Bitmap.FromHBITMAP - creates a Bitmap object based on a handle to a Windows Graphics Device Interface (GDI) bitmap and a handle to a GDI palette.
	- Bitmap.FromHICON - creates a Bitmap object based on a handle to an icon.
	- Bitmap.FromResource- creates a Bitmap object based on an application or DLL instance handle and the name of a bitmap resource.
	- Bitmap.FromStream - creates a Bitmap object based on a stream.
	- Bitmap.GetHBITMAP - creates a Windows Graphics Device Interface (GDI) bitmap from this Bitmap object.
	- Bitmap.GetHICON - creates an icon from this Bitmap object.
	- Bitmap.GetHistogram - returns one or more histograms for specified color channels of this Bitmap object.
	- Bitmap.GetHistogramSize - returns the number of elements (in an array of UINTs) that you must allocate before you call the Bitmap.GetHistogram method of a Bitmap object.
	- Bitmap.GetPixel - gets the color of a specified pixel in this bitmap.
	- Bitmap.InitializePalette - initializes a standard, optimal, or custom color palette.
	- Bitmap.LockBits - locks a rectangular portion of this bitmap and provides a temporary buffer that you can use to read or write pixel data in a specified format.
	- Bitmap.SetPixel - sets the color of a specified pixel in this bitmap.
	- Bitmap.SetResolution - sets the resolution of this Bitmap object.
	- Bitmap.UnlockBits - unlocks a portion of this bitmap that was previously locked by a call to Bitmap.LockBits.

	*/

}

; ####################################################
class Color {
; *********************************************************************************************************************
/* Class: GDipC.Color
	GDipC Color - see <https://docs.microsoft.com/de-de/windows/desktop/api/gdipluscolor/nl-gdipluscolor-color>

Authors:
	<hoppfrosch at hoppfrosch@gmx.de>: Original
*/
	; Group: Properties
	_version := "1.0.0"
	_debug := 1
	a {
		/* -------------------------------------------------------------------------------
		Property: a [get/set]
		gets/sets the alpha component of this Color object.

		See also:
		<alpha>

		Value:
		a - alpha component
		*/
			get {
				return (0xff000000 & this.ARGB) >> 24
			}
			set {
				this.ARGB := ((Min(Max(value, 0), 255), 255) << 24) | (this.r << 16) | (this.g << 8) | this.b << 0
				return value
			}
		}
		alpha {
		/* -------------------------------------------------------------------------------
		Property: alpha [get/set]
		gets/sets the alpha component of this Color object.

		See also:
		<a>

		Value:
		alpha - alpha component
		*/
			get {
				return this.a
			}
			set {
				this.a := value
				return value
			}
		}
		r {
		/* -------------------------------------------------------------------------------
		Property: r [get/set]
		gets/sets the red component of this Color object.

		See also:
		<red>

		Value:
		r - red component
		*/
			get {
				return (0x00ff0000 & this.ARGB) >> 16
			}
			set {
				this.ARGB := (this.a << 24) | (Min(Max(value, 0), 255) << 16) | (this.g << 8) | this.b << 0
				return value
			}
		}
		red {
		/* -------------------------------------------------------------------------------
		Property: red [get/set]
		gets/sets the red component of this Color object.

		See also:
		<r>

		Value:
		red - red component
		*/
			get {
				return this.r
			}
			set {
				this.r := value
				return value
			}
		}
		g {
		/* -------------------------------------------------------------------------------
		Property: g [get/set]
		gets/sets the green component of this Color object.

		See also:
		<green>

		Value:
		g - green component
		*/
			get {
				return (0x0000ff00 & this.ARGB) >> 8
			}
			set {
				this.ARGB := (this.a << 24) | (this.r << 16) | (Min(Max(value, 0), 255) << 8) | this.b << 0
				return value
			}
		}
		green {
		/* -------------------------------------------------------------------------------
		Property: green [get/set]
		gets/sets the green component of this Color object.

		See also:
		<g>

		Value:
		green - green component
		*/
			get {
				return this.g
			}
			set {
				this.g := value
				return value
			}
		}
		b {
		/* -------------------------------------------------------------------------------
		Property: b [get/set]
		gets/sets the blue component of this Color object.

		See also:
		<blue>

		Value:
		b - blue component
		*/
			get {
				return 0x000000ff & this.ARGB
			}
			set {
				this.ARGB := (this.a << 24) | (this.r << 16) | (this.g << 8) | (Min(Max(value, 0), 255) << 0)
				return value
			}
		}
		blue {
		/* -------------------------------------------------------------------------------
		Property: blue [get/set]
		gets/sets the blue component of this Color object.

		See also:
		<b>

		Value:
		blue - blue component
		*/
			get {
				return this.b
			}
			set {
				this.b := value
				return value
			}
		}
		RGB {
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
				this.b := ((value & 0x0000FF) >> 0)
				return value
			}
		}
		hex {
		/* -------------------------------------------------------------------------------
		Property: hex [get]
		Get hex-color value
		*/
			get {
				return format("0x{1:02x}{2:02x}{3:02x}{4:02x}", this.a, this.r, this.g, this.b)
			}
		}
		version {
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

	; Group: Constructors
	__new(params*)	{
	/* -------------------------------------------------------------------------------
	Constructor: __new

	The constructor supports followings parameters:

	1.) Creates a <GDipC.Color> object and initializes it to opaque black.
	==== AutoHotkey ====
	col := GDipC.Color()
	===

	2.) Creates a <GDipC.Color> object by using an ARGB value.
	==== AutoHotkey ====
	col := GDipC.Color(ARGB)
	===

	3.) Creates a <GDipC.Color> object by using specified values for the red, green, and blue components. This constructor sets the alpha component to 255 (opaque).
	==== AutoHotkey ====
	col := GDipC.Color(R, G, B)
	===

	4.) Creates a <GDipC.Color> object by using specified values for the alpha, red, green, and blue components.
	==== AutoHotkey ====
	col := GDipC.Color(A, R, G, B)
	===
	*/
		c := params.Length
		if (c = 0){
			a := 255
			r := 0
			g := 0
			b := 0
		}
		else  if (c = 1) {
			this.ARGB := params[1]
		}
		else  if (c = 3) {
			a := 255
			r := params[1]
			g := params[2]
			b := params[3]
		}
		else  if (c = 4) {
			a := params[1]
			r := params[2]
			g := params[3]
			b := params[4]
		}
		else {
			throw "Incorrect number of parameters for "  A_ThisFunc
		}
		if (c = 0 || c >= 3) {
			this.ARGB := (
				  Min(Max(a, 0), 255) << 24
				| Min(Max(r, 0), 255) << 16
				| Min(Max(g, 0), 255) << 8
				| Min(Max(b, 0), 255) << 0
			)
		}
	}
	static newFromHexRGB(hex) {
	/* ---------------------------------------------------------------------------------------
	Method: newFromHexRGB()
	Constructor - Fills values from given hex value

	Parameters:
	hex - hex color string

	Returns:
	new instance of this class

		Example:
	==== AutoHotkey ====
	col := GDipC.Color.newFromHexRGB(0x44AB4F)
	===
	*/
		Red   := ((hex & 0xFF0000) >> 16)
		Green := ((hex & 0x00FF00) >> 8)
		Blue  :=  (hex & 0x0000FF)
		obj := GdipC.Color(255,Red,Green,Blue)
		return obj
	}

	; Group: Functions

}

; ####################################################
class Graphics { ; TODO: Implementation of Graphics
	; *********************************************************************************************************************
	/* Class: GDipC.Graphics
		GDipC Graphics - see <https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nl-gdiplusgraphics-graphics>

		The Graphics class provides methods for drawing lines, curves, figures, images, and text. A Graphics object stores
		attributes of the display device and attributes of the items to be drawn.

	Authors:
		<hoppfrosch at hoppfrosch@gmx.de>: Original

	Not Yet implemented:

	- Graphics.AddMetafileComment -adds a text comment to an existing metafile.
	- Graphics.BeginContainer - begins a new graphics container.
	- Graphics.Clear - clears a Graphicsobject to a specified color.
	- Graphics.DrawArc - draws an arc. The arc is part of an ellipse.
	- Graphics.DrawBezier - draws a B�zier spline.
	- Graphics.DrawCachedBitmap - draws the image stored in a CachedBitmap object.
	- Graphics.DrawCurve - draws a cardinal spline.
	- Graphics.DrawDriverString - method draws characters at the specified positions. The method gives the client complete control over the appearance of text. The method assumes that the client has already set up the format and layout to be applied.
	- Graphics.DrawEllipse - draws an ellipse.
	- Graphics.DrawImage - draws an image.
	- Graphics.DrawLines - draws a sequence of connected lines.
	- Graphics.DrawPath - draws a sequence of lines and curves defined by a GraphicsPath object.
	- Graphics.DrawPie - draws a pie.
	- Graphics.DrawPolygon - draws a polygon.
	- Graphics.DrawRectangle - draws a rectangle.
	- Graphics.DrawRectangles - draws a sequence of rectangles.
	- Graphics.DrawString - draws a string based on a font and an origin for the string.
	- Graphics.EndContainer - closes a graphics container that was previously opened by the Graphics.BeginContainer method.
	- Graphics.EnumerateMetafile - calls an application-defined callback function for each record in a specified metafile. You can use this method to display a metafile by calling PlayRecord in the callback function.
	- Graphics.ExcludeClip - updates the clipping region to the portion of itself that does not intersect the specified rectangle.
	- Graphics.FillEllipse - uses a brush to fill the interior of an ellipse that is specified by a rectangle.
	- Graphics.FillPath - uses a brush to fill the interior of a path. If a figure in the path is not closed, this method treats the nonclosed figure as if it were closed by a straight line that connects the figure's starting and ending points.
	- Graphics.FillPie - uses a brush to fill the interior of a pie.
	- Graphics.FillPolygon - uses a brush to fill the interior of a polygon.
	- Graphics.FillRectangle - uses a brush to fill the interior of a rectangle.
	- Graphics.FillRectangles - uses a brush to fill the interior of a sequence of rectangles.
	- Graphics.Flush - flushes all pending graphics operations.
	- Graphics.FromHDC - creates a Graphics object that is associated with a specified device context.
	- Graphics.FromHWND - creates a Graphicsobject that is associated with a specified window.
	- Graphics.FromImage - creates a Graphicsobject that is associated with a specified Image object.
	- Graphics.GetClip - gets the clipping region of this Graphics object.
	- Graphics.GetClipBounds - gets a rectangle that encloses the clipping region of this Graphics object.
	- Graphics.GetCompositingMode - gets the compositing mode currently set for this Graphics object.
	- Graphics.GetCompositingQuality - gets the compositing quality currently set for this Graphics object.
	- Graphics.GetDpiX - gets the horizontal resolution, in dots per inch, of the display device associated with this Graphics object.
	- Graphics.GetDpiY - gets the vertical resolution, in dots per inch, of the display device associated with this Graphics object.
	- Graphics.GetHalftonePalette - gets a Windows halftone palette.
	- Graphics.GetHDC - gets a handle to the device context associated with this Graphics object.
	- Graphics.GetInterpolationMode - gets the interpolation mode currently set for this Graphics object. The interpolation mode determines the algorithm that is used when images are scaled or rotated.
	- Graphics.GetLastStatus - returns a value that indicates the nature of this Graphics object's most recent method failure.
	- Graphics.GetNearestColor - gets the nearest color to the color that is passed in. This method works on 8-bits per pixel or lower display devices for which there is an 8-bit color palette.
	- Graphics.GetPageScale - gets the scaling factor currently set for the page transformation of this Graphics object. The page transformation converts page coordinates to device coordinates.
	- Graphics.GetPageUnit - gets the unit of measure currently set for this Graphics object.
	- Graphics.GetPixelOffsetMode - gets the pixel offset mode currently set for this Graphics object.
	- Graphics.GetRenderingOrigin - gets the rendering origin currently set for this Graphics object.
	- Graphics.GetSmoothingMode - determines whether smoothing (antialiasing) is applied to the Graphics object.
	- Graphics.GetTextContrast - gets the contrast value currently set for this Graphics object. The contrast value is used for antialiasing text.
	- Graphics.GetTextRenderingHint - returns the text rendering mode currently set for this Graphics object.
	- Graphics.GetTransform - gets the world transformation matrix of this Graphics object.
	- Graphics.GetVisibleClipBounds - gets a rectangle that encloses the visible clipping region of this Graphics object.
	- Graphics.Graphics - constructors of the Graphics class
	- Graphics.IntersectClip - updates the clipping region of this Graphics object to the portion of the specified rectangle that intersects with the current clipping region of this Graphics object.
	- Graphics.IsClipEmpty - determines whether the clipping region of this Graphics object is empty.
	- Graphics.IsVisible - determines whether the specified point is inside the visible clipping region of this Graphics object.
	- Graphics.IsVisibleClipEmpty - determines whether the visible clipping region of this Graphics object is empty. The visible clipping region is the intersection of the clipping region of this Graphics object and the clipping region of the window.
	- Graphics.MeasureCharacterRanges - gets a set of regions each of which bounds a range of character positions within a string.
	- Graphics.MeasureDriverString - measures the bounding box for the specified characters and their corresponding positions.
	- Graphics.MeasureString - measures the extent of the string in the specified font, format, and layout rectangle.
	- Graphics.MultiplyTransform - updates this Graphics object's world transformation matrix with the product of itself and another matrix.
	- Graphics.ReleaseHDC - releases a device context handle obtained by a previous call to the - Graphics.GetHDC method of this Graphics object.
	- Graphics.ResetClip - sets the clipping region of this Graphics object to an infinite region.
	- Graphics.ResetTransform - sets the world transformation matrix of this Graphics object to the identity matrix.
	- Graphics.Restore - sets the state of this Graphics object to the state stored by a previous call to the - Graphics.Save method of this Graphics object.
	- Graphics.RotateTransform - updates the world transformation matrix of this Graphics object with the product of itself and a rotation matrix.
	- Graphics.Save - saves the current state (transformations, clipping region, and quality settings) of this Graphics object. You can restore the state later by calling the - Graphics.Restore method.
	- Graphics.ScaleTransform - updates this Graphics object's world transformation matrix with the product of itself and a scaling matrix.
	- Graphics.SetAbort - Not used in Windows GDI+ versions 1.0 and 1.1.
	- Graphics.SetClip - updates the clipping region of this Graphics object.
	- Graphics.SetCompositingMode - sets the compositing mode of this Graphics object.
	- Graphics.SetCompositingQuality - sets the compositing quality of this Graphics object.
	- Graphics.SetInterpolationMode - sets the interpolation mode of this Graphics object. The interpolation mode determines the algorithm that is used when images are scaled or rotated.
	- Graphics.SetPageScale - sets the scaling factor for the page transformation of this Graphics object. The page transformation converts page coordinates to device coordinates.
	- Graphics.SetPageUnit - sets the unit of measure for this Graphics object. The page unit belongs to the page transformation, which converts page coordinates to device coordinates.
	- Graphics.SetPixelOffsetMode - sets the pixel offset mode of this Graphics object.
	- Graphics.SetRenderingOrigin - sets the rendering origin of this Graphics object. The rendering origin is used to set the dither origin for 8-bits-per-pixel and 16-bits-per-pixel dithering and is also used to set the origin for hatch brushes.
	- Graphics.SetSmoothingMode - sets the rendering quality of the Graphics object.
	- Graphics.SetTextContrast - sets the contrast value of this Graphics object. The contrast value is used for antialiasing text.
	- Graphics.SetTextRenderingHint - sets the text rendering mode of this Graphics object.
	- Graphics.SetTransform - sets the world transformation of this Graphics object.
	- Graphics.TransformPoints - converts an array of points from one coordinate space to another. The conversion is based on the current world and page transformations of this Graphics object.
	- Graphics.TranslateClip - translates the clipping region of this Graphics object.
	- Graphics.TranslateTransform - updates this Graphics object's world transformation matrix with the product of itself and a translation matrix.

	*/
	_version := "0.1.0"

	__new(params*) {
	/* -------------------------------------------------------------------------------
	Constructor: __new

	The constructor supports followings parameters:

	1.) Creates a <GDipC.Graphics> object that is associated with a specified device context.
	==== AutoHotkey ====
	oGraphics := GDipC.Graphics(hdc)
	===

	2.) Creates a <GDipC.Graphics> object that is associated with an <GDipC.Image> object.
	==== AutoHotkey ====
	oGraphics := GDipC.Graphics(oImage)
	===

	3.) Creates a <GDipC.Graphics> object that is associated with a specified window.
	==== AutoHotkey ====
	oGraphics := GDipC.Graphics(hwnd, flag)
	===

	4.) Creates a <GDipC.Graphics> object that is  associated with a specified device context and a specified device.
	==== AutoHotkey ====
	oGraphics := GDipC.Graphics(hdc, handle)
	===
	*/
		c := params.Length
		if (c = 1) {
			this.pGraphics := this.GraphicsFromHDC(this.hdc)
		}
		else  if (c = 2) {
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
		else {
			throw "Incorrect number of parameters for "  A_ThisFunc
		}
	}

	version {
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
class Pen { ; TODO: Implementation of Pen
; *********************************************************************************************************************
/* Class: GDipC.Pen
	GDI+ Pen (see <https://docs.microsoft.com/en-us/windows/win32/api/gdipluspen/nl-gdipluspen-pen>)
	The <GDipC.Pen> object is used to draw contours and lines.

	Not Yet implemented:

	- Pen.Clone - copies a Pen object.
	- Pen.GetAlignment - gets the alignment currently set for this Pen object.
	- Pen.GetBrush - gets the Brush object that is currently set for this Pen object.
	- Pen.GetColor - gets the color currently set for this Pen object.
	- Pen.GetCompoundArray - gets the compound array currently set for this Pen object.
	- Pen.GetCompoundArrayCount - gets the number of elements in a compound array.
	- Pen.GetCustomEndCap - gets the custom end cap currently set for this Pen object.
	- Pen.GetCustomStartCap gets the custom start cap currently set for this Pen object.
	- Pen.GetDashCap - gets the dash cap style currently set for this Pen object.
	- Pen.GetDashOffset - the distance from the start of the line to the start of the first space in a dashed line.
	- Pen.GetDashPattern - gets an array of custom dashes and spaces currently set for this Pen object.
	- Pen.GetDashPatternCount - gets the number of elements in a dash pattern array.
	- Pen.GetDashStyle - gets the dash style currently set for this Pen object.
	- Pen.GetEndCap - gets the end cap currently set for this Pen object.
	- Pen.GetLastStatus - returns a value that indicates the nature of this Pen object's most recent method failure.
	- Pen.GetLineJoin - gets the line join style currently set for this Pen object.
	- Pen.GetMiterLimit - gets the miter length currently set for this Pen object.
	- Pen.GetPenType - gets the type currently set for this Pen object.
	- Pen.GetStartCap - gets the start cap currently set for this Pen object.
	- Pen.GetTransform - gets the world transformation matrix currently set for this Pen object.
	- Pen.GetWidth - gets the width currently set for this Pen object.
	- Pen.MultiplyTransform - updates the world transformation matrix of this Pen object with the product of itself and another matrix.
	- Pen.Pen - Creates a Pen object
	- Pen.ResetTransform - sets the world transformation matrix of this Pen object
	- Pen.ScaleTransform - sets the Pen object's world transformation matrix equal to the product of itself and a scaling matrix.
	- Pen.SetAlignment - sets the alignment for this Pen object relative to the line.
	- Pen.SetBrush - sets the Brush object that a pen uses to fill a line.
	- Pen.SetColor - sets the color for this Pen object.
	- Pen.SetCompoundArray - sets the compound array for this Pen object.
	- Pen.SetCustomEndCap - sets the custom end cap for this Pen object.
	- Pen.SetCustomStartCap - sets the custom start cap for this Pen object.
	- Pen.SetDashCap - sets the dash cap style for this Pen object.
	- Pen.SetDashOffset - sets the distance from the start of the line to the start of the first dash in a dashed line.
	- Pen.SetDashPattern - sets an array of custom dashes and spaces for this Pen object.
	- Pen.SetDashStyle - sets the dash style for this Pen object.
	- Pen.SetEndCap - sets the end cap for this Pen object.
	- Pen.SetLineCap - sets the cap styles for the start, end, and dashes in a line drawn with this pen.
	- Pen.SetLineJoin - sets the line join for this Pen object.
	- Pen.SetMiterLimit - sets the miter limit of this Pen object.
	- Pen.SetStartCap - sets the start cap for this Pen object.
	- Pen.SetTransform - sets the world transformation of this Pen object.
	- Pen.SetWidth - sets the width for this Pen object.

Authors:
	<hoppfrosch at hoppfrosch@gmx.de>: Original
*/
}

; ####################################################
class Point {
; *********************************************************************************************************************
/* Class: GDipC.Point
	GDipC Point - see <https://msdn.microsoft.com/en-us/library/windows/desktop/ms534487(v=vs.85).aspx>

Authors:
	<hoppfrosch at hoppfrosch@gmx.de>: Original
*/
	_version := "1.0.0"
	X := 0
	Y := 0

	; Group: Properties
	/* Property: x [get/set]
	Get or Set x-coordinate of the point

	Value:
	x -  x-coordinate of the point
	*/
	/* Property: y [get/set]
	Get or Set y-coordinate of the point

	Value:
	y -  y-coordinate of the point
	*/
	version {
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

	; Group: Constructors
	__new(params*) {
	/* -------------------------------------------------------------------------------
	Constructor: __new

	The constructor supports followings parameters:

	1.) Creates a <GDipC.Point> object and initializes the X and Y data members to zero.
	==== AutoHotkey ====
	pt := GDipC.Point()
	===

	2.) Creates a <GDipC.Point> object using two integers to initialize the X and Y data members.
	==== AutoHotkey ====
	pt := GDipC.Point(X, Y)
	===

	3.) Creates a <GDipC.Point> objectand copies the data members from another Point object.
	==== AutoHotkey ====
	pt := GDipC.Point(pt1)
	===

	4.) Creates a <GDipC.Point> object and using a <GDipC.Size> object to initialize the X and Y data members.
	==== AutoHotkey ====
	sz := GDipC.Size(100,110)
	pt := GDipC.Point(sz)
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
	static fromMouse() {
		/* --------------------------------------------------------------------------------------
		Method: fromMouse()
		Creates a new instance from current mouseposition

		Example:

		==== AutoHotkey ====
		pt := GdipC.Point.fromMouse()
		===
		*/
		prevCoordMode := A_CoordModeMouse
		CoordMode("Mouse", "Screen")
		MouseGetPos(&x, &y)
		r := GdipC.Point(x, y)
		CoordMode("Mouse", prevCoordMode)
		return r
	}

	; Group: Functions
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
			return GDipC.Point((this.X + params[1]),(this.Y + params[2]))
		}
		if (c = 1) {
			if (params[1].__Class == "GdipC.Point") {
				return GDipC.Point((this.X + params[1].X),(this.Y + params[1].X))
			}
			else if (params[1].__Class == "GdipC.Size") {
				return GDipC.Point((this.X + params[1].Width),(this.Y + params[1].Height))
			}
			else {
				throw "Incorrect parameter class for " A_ThisFunc
			}
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
			return GDipC.Point((this.X - params[1]),(this.Y - params[2]))
		}
		if (c = 1) {
			if (params[1].__Class == "GdipC.Point") {
				return GDipC.Point((this.X - params[1].X),(this.Y - params[1].X))
			}
			else if (params[1].__Class == "GdipC.Size") {
				return GDipC.Point((this.X - params[1].Width),(this.Y - params[1].Height))
			}
			else {
				throw "Incorrect parameter class for " A_ThisFunc
			}
		}
		else {
			throw "Incorrect number of parameters for "  A_ThisFunc
		}
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

}

; ####################################################
class Rect {
; *********************************************************************************************************************
/* Class: GDipC.Rect
	GDipC Rect - see <https://msdn.microsoft.com/en-us/library/windows/desktop/ms534495(v=vs.85).aspx>

Authors:
	<hoppfrosch at hoppfrosch@gmx.de>: Original
*/
	_version := "1.0.0"

	; Group: Properties
	/* ---------------------------------------------------------------------------------------
	Property: x [get/set]
	Get or Set x-coordinate of the upper left corner of the rectangle

	Value:
	x -  x-coordinate of the upper left corner of the rectangle

	See Also:
	<xul>
	*/
	/* ---------------------------------------------------------------------------------------
	Property: y [get/set]
	Get or Set y-coordinate of the upper left corner of the rectangle

	Value:
	y -  y-coordinate of the upper left corner of the rectangle

	See Also:
	<yul>
	*/
		/* ---------------------------------------------------------------------------------------
		Property: width [get/set]
		Get or Set the width of the rectangle

		Value:
		width -  width of the rectangle
		*/
		/* ---------------------------------------------------------------------------------------
		Property: height [get/set]
		Get or Set the height of the rectangle

		Value:
		height -  height of the rectangle
		*/
	xul {
	/* -------------------------------------------------------------------------------
	Property: xul [get/set]
	Get or Set x-coordinate of the upper left corner of the rectangle

	Value:
	xul -  x-coordinate of the upper left corner of the rectangle

	See Also: <x>, <getTop>
	*/
		get {
			return this.x
		}
		set {
			this.x := value
			return this.x
		}
	}
	yul {
	/* -------------------------------------------------------------------------------
	Property: yul [get/set]
	Get or Set y-coordinate of the upper left corner of the rectangle

	Value:
	y -  y-coordinate of the upper left corner of the rectangle

	See Also: <y>, <getLeft>
	*/
		get {
			return this.y
		}
		set {
			this.y := value
			return this.y
		}
	}
	xlr {
	/* -------------------------------------------------------------------------------
	Property: xlr [get/set]
	Get or Set x-coordinate of the lower right corner of the rectangle

	Value:
	xlr -  x-coordinate of the lower right corner of the rectangle

	see: <getBottom>
	*/
		get {
			return this.x+this.width
		}
		set {
			this.width := value - this.x
			return value
		}
	}
	ylr {
	/* -------------------------------------------------------------------------------
	Property: ylr [get/set]
	Get or Set y-coordinate of the lower right corner of the rectangle

	Value:
	ylr -  y-coordinate of the lower right corner of the rectangle

	see: <getRight>
	*/
		get {
			return this.y+this.height
		}
		set {
			this.height := value - this.y
			return value
		}
	}
	version {
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

	; Group: Constructors
	__new(params*) {
	/* -------------------------------------------------------------------------------
	Constructor: __new

	The constructor supports followings parameters:

	1.) Creates a <GDipC.Rect> object whose x-coordinate, y-coordinate, width, and height are all zero.
	==== AutoHotkey ====
	rect := GDipC.Rect()
	===

	2.) Creates a <GDipC.Rect> object by using four integers to initialize the X, Y, Width, and Height data members.
	==== AutoHotkey ====
	rect := GDipC.Rect(X, Y, Width, Height)
	===

	3.) Creates a <GDipC.Rect> objectby using a <GDipC.Point> object to initialize the X and Y data members and a <GDipC.Size> object to initialize the Width and Height data members.
	==== AutoHotkey ====
	pt := GDipC.Point(10, 20)
	sz := GDipC.Size(100, 200)
	rect := GDipC.Rect(pt, sz)
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
	static fromHwnd(hwnd) {
		/* ---------------------------------------------------------------------------------------
		Method: fromHwnd(hwnd)
		Contructs a new <GDipC.Rect> instance from window given via hwnd

		Parameters:
			hWnd - Window handle, whose geometry has to be determined

		Example:
		==== AutoHotkey ====
		rect1 := GDipC.Rect.fromHwnd(hwnd)
		===
		*/
			WinGetPos &x, &y, &w, &h, "ahk_id " hwnd
			r := GdipC.Rect(x, y, w, h)
			return r
	}

	; Group: Functions
	clone() {
	/* --------------------------------------------------------------------------------------
	Method: clone()
	creates a new <GDipC.Rect> object and initializes it with the contents of this Rect object.

	Example:
	==== AutoHotkey ====
	rect2 := rect1.clone()
	===
	*/
		r := GDipC.Rect(this.x, this.y, this.width, this.height)
		return r
	}
	contains(params*) {
	/* --------------------------------------------------------------------------------------
	Method: contains()
	The method <GDipC.Rect.contains> checks whether anther object is within the given rectangle. Following overloaded methods are supported:

	1.) determines whether the <GDipC.Point> is inside this rectangle.
	==== AutoHotkey ====
	rect := GDipC.Rect(0, 0, 50, 50)
	pt := GDipC.Point(10, 20)
	contains := rect.contains(pt)
	===

	2.) determines whether the point (x,y) is inside this rectangle.
	==== AutoHotkey ====
	rect := GDipC.Rect(0, 0, 50, 50)
	contains := rect.contains(10,20)
	===

	3.) determines whether another <GDipC.Rect> is inside this rectangle.
	==== AutoHotkey ====
	rect1 := GDipC.Rect(0, 0, 50, 50)
	rect2 := GDipC.Rect(10, 10, 20, 20)
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

	see also: <GDipC.Rect.equalsPos>, <GDipC.Rect.equalsSize>,

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
	equalsLocation(params*) {
	/* --------------------------------------------------------------------------------------
	Method: equalsPos()
	determines whether two rectangles do have the same position.

	see also: <GDipC.Rect.equals>, <GDipC.Rect.equalsSize>,

	Example:
	==== AutoHotkey ====
	equal := rect1.equalsPos(rect2)
	===
	*/
	c := params.Length
	if (c = 1) {
		if (params[1].__Class == "GdipC.Rect") {
			if ((params[1].x == this.x) && (params[1].y == this.y)) {
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
	equalsSize(params*) {
	/* --------------------------------------------------------------------------------------
	Method: equalsSize()
	determines whether two rectangles do have the same size.

	see also: <GDipC.Rect.equals>, <GDipC.Rect.equalsPos>,

	Example:
	==== AutoHotkey ====
	equal := rect1.equalsSize(rect2)
	===
	*/
		c := params.Length
		if (c = 1) {
			if ((params[1].__Class == "GdipC.RectEx") || (params[1].__Class == "GdipC.Rect")) {
				if ((params[1].width == this.width) && (params[1].height == this.height)) {
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

	see: <ylr>

	Example:
	==== AutoHotkey ====
	bot := rect.getBottom()
	===
	*/
		return this.ylr
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

	see: <x>, <xul>

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
	gets the coordinates of the upper-left corner of the rectangle as a <GDipC.Point> object.

	Example:
	==== AutoHotkey ====
	pt := rect.getLocation()
	===
	*/
		pt := GDipC.Point(this.x, this.y)
		return pt
	}
	getRight() {
	/* --------------------------------------------------------------------------------------
	Method: getRight()
	gets the x-coordinate of the right edge of the rectangle.

	see: <xlr>

	Example:
	==== AutoHotkey ====
	lft := rect.getRight()
	===
	*/
		return this.xlr
	}
	getSize() {
	/* --------------------------------------------------------------------------------------
	Method: getSize()
	gets the width and height of the rectangle as an <GDipC.Size> object.

	Example:
	==== AutoHotkey ====
	pt := rect.getSize()
	===
	*/
		sz := GDipC.Size(this.width, this.height)
		return sz
	}
	getTop() {
	/* --------------------------------------------------------------------------------------
	Method: getTop()
	gets the y-coordinate of the top edge of the rectangle.

	see: <yul>, <y>

	Example:
	==== AutoHotkey ====
	bot := rect.getTop()
	===
	*/
		return this.y
	}
	inflate(params*) {
	/* --------------------------------------------------------------------------------------
	Method: inflate()
	expands the rectangle. Following overloaded methods are supported:

	1.) expands the rectangle by dx on the left and right edges, and by dy on the top and bottom edges.
	==== AutoHotkey ====
	rect := GDipC.Rect(0, 0, 50, 50)
	rect.inflate(10,20)
	===

	2.) expands the rectangle by the value of <GDipC.Point> X on the left and right edges, and by the value of <GDipC.Point> Y on the top and bottom edges.
	==== AutoHotkey ====
	rect := GDipC.Rect(0, 0, 50, 50)
	pt := GDipC.Point(10, 20)
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
	rect1 := GDipC.Rect(0, 0, 50, 50)
	rect2 := GDipC.Rect(10, 10, 50, 50)
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
				ret := GDipC.Rect(left, top, right-left, bottom-top)
				bIntersects := !ret.isEmptyArea()
				if (!bIntersects) {
					; if they don't intersect the result is an null-sized rectangle
					ret := GDipC.Rect()
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
	rect1 := GDipC.Rect(0, 0, 50, 50)
	rect2 := GDipC.Rect(10, 10, 50, 50)
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
	rect := GDipC.Rect(10, 20, 0, 0)
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
	rect := GDipC.Rect(0, 0, 50, 50)
	rect.offset(10,20)
	===

	2.) moves this rectangle horizontally a distance of <GDipC.Point> X and vertically a distance of <GDipC.Point> Y.
	==== AutoHotkey ====
	rect := GDipC.Rect(0, 0, 50, 50)
	pt := GDipC.Point(10, 20)
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
	union(params *) {
	/* --------------------------------------------------------------------------------------
	Method: union()
	determines the union of two rectangles and stores the result in a >GDipC.Rect> object.

	Example:
	==== AutoHotkey ====
	rect1 := GDipC.Rect(10, 20, 100, 100)
	rect2 := GDipC.Rect(20, 30, 200, 2000)
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
}

; ####################################################
class Size {
	; *********************************************************************************************************************
	/* Class: GDipC.Size
		GDipC Size - see <https://msdn.microsoft.com/en-us/library/windows/desktop/ms534504(v=vs.85).aspx>

	Authors:
		<hoppfrosch at hoppfrosch@gmx.de>: Original
	*/

	; Group: Properties
		_version := "1.0.0"
		Width := 0
		Height := 0

	/* Property: width [get/set]
	Get or Set width-component of object
	*/
	/* Property: height [get/set]
	Get or Set width-component of object
	*/
	version {
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

	; Group: Constructors
		__new(params*)	{
		/* -------------------------------------------------------------------------------
		Constructor: __new

		The constructor supports followings parameters:

		1.) Creates a <GDipC.Size> object and initializes the Width and Height data members to zero.
		==== AutoHotkey ====
		sz := GDipC.Size()
		===

		2.) Creates a <GDipC.Size> object using two integers to initialize the Width and Height data members.
		==== AutoHotkey ====
		sz := GDipC.Size(Width, Height)
		===

		3.) Creates a <GDipC.Size> objectand copies the data members from another Size object.
		==== AutoHotkey ====
		sz := GDipC.Size(sz1)
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

	; Group: Functions
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
				return GdipC.Point((this.Width + params[1].Width),(this.Height + params[1].Height))
			}
			else {
				throw "Incorrect parameter class for " A_ThisFunc
			}
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
				return GdipC.Size((this.Width - params[1]),(this.Height - params[2]))
			}
			if (c = 1) {
				if (params[1].__Class == "GdipC.Size") {
					return GdipC.Point((this.Width - params[1].Width),(this.Height - params[1].Height))
				}
				else {
					throw "Incorrect parameter class for " A_ThisFunc
				}
			}
			else {
				throw "Incorrect number of parameters for "  A_ThisFunc
			}
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

; ####################################################
}