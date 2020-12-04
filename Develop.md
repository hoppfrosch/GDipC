# Develop and build GDipC

## Development tools

* documentation generation from sourcecode: [NaturalDocs](https://www.naturaldocs.org/)

## Building the Documentation

Go into folder *_build* and run script *mkDoc.ahkÜ

## Auto-Build documentation on commit

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
	./autohotkey.exe mkDoc.ahk
	popd
    git add docs
	git add lib
    git commit --amend -C HEAD --no-verify
fi
exit
```