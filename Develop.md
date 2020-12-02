# Directory structure

# Development tools

* preprocessor *gpp*: ([General Purpose Preprocessor](https://github.com/makc/gpp.2.24-windows))

* documentation generation from sourcecode: [NaturalDocs](https://www.naturaldocs.org/)
  
* Unittest-Framework: [YUnit](https://github.com/Uberi/Yunit)

* [AutoHotkey]

# Official distribution is build via preprocessing source files

The distribution files are to be build/copied from the *src* folder to the *lib* folder. This release process is done by executing the script *_build\Build.ahk*. Within this scripts the following steps are done:

* Using the preprocessor *gpp* files from folder *src* are combined and released to folder *lib*. As each class is in its own file within the *src* folder, *gpp* uses standard include techniques to combine several different files into single files, which are copied to the folder *lib*

* copy files from folder *src* into folder *lib*.

The files to be copied and to be preprocessed via *gpp* are hardcoded within the file *_build\Build.ahk*. If new files are to be added to the folder *Src* the file *_build\Build.ahk* has to be adapted.

# Building the Documentation

# Auto-Build distribution and documentation on commit

You can use git hooks to build the distribution and documentation files on the fly: on each commit those files can be generated via git hook and be added to the current commit. To enable this you have to add the following files/hooks to your folder *.git/hooks*:

1.) Filename *pre-commit* 
Contents;
```bash
#!/bin/sh
echo 
touch .commit 
exit
```

2.) Filename *pre-commit* 
Contents;
```bash
#!/bin/sh
#
echo
if [ -a .commit ]
    then
    rm .commit
	pushd _build
	./autohotkey.exe Build.ahk
	./autohotkey.exe mkdoc.ahk
	popd
    git add docs
	git add lib
    git commit --amend -C HEAD --no-verify
fi
exit
```

# Unittests

* On sourcecode-modification write your own unittests within `t` folder 

* run the existing unittests to be sure everything is ok ...

# Using log4ahk for logging and debugging purposes