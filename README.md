# GdipC-Development [![AutoHotkey2](https://img.shields.io/badge/Language-AutoHotkey2-red.svg)](https://autohotkey.com/)


AutoHotkey implementation of several GDI+ Classes (see [GDI+-Documentation](https://msdn.microsoft.com/en-us/library/windows/desktop/ms534487(v=vs.85).aspx))
and implementation of some class extensions

This library uses *AutoHotkey Version 2*.


## Usage 

Include preprocessed `GdipC.ahk` from the `lib` folder into your project using standard AutoHotkey-include methods.

```autohotkey
#include <gdipc.ahk>
pt := new GdipC.Point(10,20)
```

For usage examples have a look at the demo programs in `demos` folder

## Development

For more information on development of this library see [Development documentation](develop.md)