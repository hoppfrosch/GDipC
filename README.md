# GdipC [![AutoHotkey2](https://img.shields.io/badge/Language-AutoHotkey2-red.svg)](https://autohotkey.com/) [![AutoHotkey2](https://img.shields.io/badge/version-AutoHotkey_2.0.a122-orange)](https://www.autohotkey.com/download/2.0/AutoHotkey_2.0-a122-f595abc2.zip)


AutoHotkey implementation of several GDI+ Classes (see [GDI+-Documentation](https://msdn.microsoft.com/en-us/library/windows/desktop/ms534487(v=vs.85).aspx))
and implementation of some class extensions

## Usage 

Include `GdipC\GdipC.ahk` from the `lib` folder into your project using standard AutoHotkey-include methods.

```autohotkey
#include <gdipc\gdipc.ahk>

pt := new GdipC.Point(10,20)
```

For usage examples have a look at the demo programs in `demos` folder

## Development

For more information on development of this library see [Development documentation](develop.md)