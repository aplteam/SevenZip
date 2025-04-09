_**Note that this project is retiered: there will be no new versions (though we are going to keep fixing bugs for a while**_

**Use https://github.com/aplteam/DotNetZip instead**

# Compressing files from Dyalog APL

This class is a wrapper that allows you to use 7zip from within Dyalog APL.


## Warning 

Note that 7zip issues an error when you pass something like this with the flag to preserve the directory structure:

```
C:\My\folder1\file.txt
C:\My\folder2\file.txt
```

This is clearly a bug. However, you can easily get around this by executing the command within `C:\My` and this list of files:
```
folder1\file.txt
folder2\file.txt
```

In other words, relative paths are fine, but absolute ones are not.

Since version 1.1.0 the `SevenZip` class issues in hint if this error occurs and absolute path names are used.


## Overview 

The class "SevenZip" relies on an installed version of the Open Source zipper [7zip](http://www.7-zip.org/).

The class makes it very easy to zip and unzip stuff.

"SevenZip" supports the following formats:
 * 7z
 * split
 * zip
 * gzip
 * bzip2
 * ta
You can either specify an appropriate extension or set the "type" property in order to enforce a particular format.

```
      myZipper←⎕new #.SevenZip (,⊂'MyZipFile')
      ⎕←myZipper
[SevenZip@MyZipFile]
      myZipper.Add 'foo.txt'
      ⎕←myZipper.List 0
foo.txt
myZipper.Unzip 'c:\output\'
```
