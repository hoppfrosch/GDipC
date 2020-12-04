; ####################################################
/*
Title: ClassHelper
	
Misc helper functions for classes
			
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

class ClassHelper {
; ***********************************************************************************************************
	static newFromString(str, Args*) {
	/* --------------------------------------------------------------------------------------
	Function: newFromString()
	Constructs a new instance of a class given by dot-separated string

	Parameters:
	str - dot separated string
	args* - parameters for class to be constructed

	Returns:
	New instance of class

	Example:
	==== AutoHotkey ====
	class b { class c { } }
	cn := "b.c"
	c :=  ClassHelper.newFromString(cn)
	===

	Credits: 
	- swagfag in <Create nested class instance from variable: https://www.autohotkey.com/boards/viewtopic.php?f=82&t=83945>
	*/ 
		ClassNames := StrSplit(str, '.')
		__GenericClass := %ClassNames.RemoveAt(1)%

		for name in ClassNames
			__GenericClass := __GenericClass.%name%

		return __GenericClass.New(Args*)
	}

	static newFromJSON(str) {
	/* --------------------------------------------------------------------------------------
	Method: newFromJSON()
	Converts JSON into new Object. The object class is taken from the "_class" entry within JSON

	Parameter :
	str - JSON-String

	Example:
	==== AutoHotkey ====
	obj := ClassHelper.newFromJSON(strJSON)
	===
	*/
		value := Jxon_Load( str )
		ct := value["_class"]
		r :=  ClassHelper.newFromString(ct, value["X"], value["Y"])
		For Name  in r.OwnProps() {
			if !RegExMatch(name, "^(_version|_class)$") {
				r.%name% := Value[name]
			}
		}
		return r
	}

	static toJSON(obj, indent:=0) {
	/* -------------------------------------------------------------------------------
	Method: toJSON()
	Converts Object into JSON

	Example:
	==== AutoHotkey ====
	str := ClassHelper.toJSON(obj, indent := 2)
	===
	*/
		; Create a map containing the class properties
		clone := Map()
		for key, value in obj.OwnProps() {
			if !RegExMatch(key, "^(_version|_class)$") {
				clone[key]:=value
			}
		}
		clone["_class"] := type(obj)

		str := Jxon_Dump(clone,indent)

		return str
	}
}