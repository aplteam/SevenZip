﻿f:Class WinFile
⍝ Provides information about files and directories without using any .NET stuff.
⍝ Many methods (Dir+DirX for example) are MUCH faster than the .NET stuff.
⍝ The class contains shared methods only.
⍝ All methods throw exceptions in case of an error.
⍝ == Indexers
⍝ Note that there are field available since version 1.7.0 useful to index the _
⍝ matrix returned by ""DirX"". The field start with "COL_" and "FA_" (for the _
⍝ file attributes). They assume a ⎕IO of 1. If you use ⎕IO you have two options:
⍝ Use the
⍝ ""#.WinFile.((DirX'')[;COL_CreationDateName,COL_LastWriteDate,COL_LastAccessDate])""
⍝ syntax or the
⍝ ""(#.WinFile.DirX '')[;COL_CreationDateName,COL_LastWriteDate,COL_LastAccessDate-~⎕IO]""
⍝ syntax.
⍝ Kai Jaeger ⋄ APL Team Ltd
⍝ Homepage: http://github.com/aplteam/WinFile

    ⎕IO←1 ⋄ ⎕ml←3

    :Include APLTreeUtils

    ∇ r←Version
      :Access Public shared
      r←(⍕⎕THIS)'1.7.3' '2011-08-12'
    ∇

    ∇ r←History
      :Access Public Shared
      r←'See: http://aplwiki.com/WinFile/ProjectPage'
    ∇

    :Field Public Shared ReadOnly FA_READONLY←37            ⍝ 1 0x1	        A file that is read-only.
    :Field Public Shared ReadOnly FA_HIDDEN←36	             ⍝ 2 0x2	        The file or directory is hidden. It is not included in an ordinary directory listing.
    :Field Public Shared ReadOnly FA_SYSTEM←35	             ⍝ 4 0x4	        A file or directory that the operating system uses a part of, or uses exclusively.
    :Field Public Shared ReadOnly FA_DIRECTORY←34	          ⍝ 16 0x10	      Flag that identifies a directory.
    :Field Public Shared ReadOnly FA_ARCHIVE←33	            ⍝ 32 0x20	      A file or directory that is an archive file or directory.
    :Field Public Shared ReadOnly FA_DEVICE←32	             ⍝ 64 0x40	      This value is reserved for system use.
    :Field Public Shared ReadOnly FA_NORMAL←31	             ⍝ 128 0x80	     A file that does not have other attributes set.
    :Field Public Shared ReadOnly FA_TEMPORARY←30	          ⍝ 256 0x100	    A file that is being used for temporary storage.
    :Field Public Shared ReadOnly FA_SPARSE_FILE←29	        ⍝ 512 0x200	    A file that is a sparse file.
    :Field Public Shared ReadOnly FA_REPARSE_POINT←28	      ⍝ 1024 0x400	   A file or directory that has an associated reparse point, or a file that is a symbolic link.
    :Field Public Shared ReadOnly FA_COMPRESSED←27	         ⍝ 2048 0x800	   A file or directory that is compressed.
    :Field Public Shared ReadOnly FA_OFFLINE←26	            ⍝ 4096 0x1000	  The data of a file is not available immediately (offline storage).
    :Field Public Shared ReadOnly FA_NOT_CONTENT_INDEXED←25 ⍝ 8192 0x2000	  The file or directory is not to be indexed by the content indexing service.
    :Field Public Shared ReadOnly FA_ENCRYPTED	←24          ⍝ 16384 0x4000	 A file or directory that is encrypted.
    :Field Public Shared ReadOnly FA_VIRTUAL←22	            ⍝ 65536 0x10000 This value is reserved for system use.

    :Field Public Shared ReadOnly COL_Name←1	               ⍝ Full name
    :Field Public Shared ReadOnly COL_ShortName←2           ⍝ 8.3 name
    :Field Public Shared ReadOnly COL_Size←3                ⍝ Size in bytes
    :Field Public Shared ReadOnly COL_CreationDateName←4	   ⍝ File creation date
    :Field Public Shared ReadOnly COL_LastAccessDate←5      ⍝ Last access date
    :Field Public Shared ReadOnly COL_LastWriteDate←6	      ⍝ Last write date


    ∇ R←{noSplit}ReadAnsiFile filename;No;Size;⎕IO;⎕ML
 ⍝ Read contents as chars. File is tied in shared mode.
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      noSplit←{0<⎕NC ⍵:⍎⍵ ⋄ 0}'noSplit'
      filename←CorrectForwardSlash filename
      filename~←'"'
      No←filename ⎕NTIE 0,66
      Size←⎕NSIZE No
      R←⎕NREAD No,82,Size,0
      ⎕NUNTIE No
      :If ~noSplit
          :If 0<+/(⎕UCS 13 10)⍷R
              R←Split R
          :ElseIf (⎕UCS 10)∊R
              R←(⎕UCS 10)Split R
          :EndIf
      :EndIf
    ∇

    ∇ {r}←Data WriteAnsiFile filename;No;CrLf;⎕IO;⎕ML
    ⍝ Data must be a string or a vtv. If file already exists it is replaced
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      CrLf←⎕TC[2 3]
      :Trap 22
          No←(filename~'"')⎕NTIE 0
          (filename~'"')⎕NERASE No
      :EndTrap
      No←(filename~'"')⎕NCREATE 0
      :Select ≡Data
      :Case 0
          Data←Data,CrLf
      :Case 1
          :If 2=⍴⍴Data
              Data←Data,((↑⍴Data),2)⍴CrLf
          :EndIf
      :Case 2
          Data←∊Data,¨⊂CrLf
      :Else
          11 ⎕SIGNAL'Domain Error: check data'
      :EndSelect
      Data ⎕NAPPEND No
      ⎕NUNTIE No
      r←''
    ∇

    ∇ R←Cd Name;Rc;∆GetCurrentDirectory;∆SetCurrentDirectory;⎕IO;⎕ML
    ⍝ Report/change the current directory
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      Name←CorrectForwardSlash Name
      '∆GetCurrentDirectory'⎕NA'I4 KERNEL32.C32|GetCurrentDirectory',('*A'⊃⍨1+12>{⍎⍵↑⍨¯1+⍵⍳'.'}2⊃'.'⎕WG'APLVersion'),' I4 >T[]'
      '∆SetCurrentDirectory'⎕NA'I4 KERNEL32.C32|SetCurrentDirectory',('*A'⊃⍨1+12>{⍎⍵↑⍨¯1+⍵⍳'.'}2⊃'.'⎕WG'APLVersion'),' <0T'
      :If 0=↑Rc←∆GetCurrentDirectory 260 260
          R←GetLastError'GetCurrentDirectory error' ''
      :Else
          R←↑↑/Rc
      :EndIf
      :If ~0∊⍴Name←Name~'"'
      :AndIf ' '=1↑0⍴Name
          Name,←('\'≠¯1↑Name)/'\'
          :If ~∆SetCurrentDirectory⊂Name
              11 ⎕SIGNAL⍨⊃{⍵,'; rc=',⍕⍺}/GetLastError'SetCurrentDirectory error'
          :EndIf
      :EndIf
    ∇

    ∇ {r}←Source CopyTo Target;∆CopyFile;⎕IO;⎕ML
    ⍝ Copy "Source" to "Target"
    ⍝ Examples:
    ⍝ 'C:\readme.txt' #.WinFile.CopyTo 'D:\buffer\'
    ⍝ 'C:\readme.txt' #.WinFile.CopyTo 'D:\buffer\newname.txt'
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      Source←CorrectForwardSlash Source
      Target←CorrectForwardSlash Target
      '∆CopyFile'⎕NA'I kernel32.C32|CopyFile',('*A'⊃⍨1+12>{⍎⍵↑⍨¯1+⍵⍳'.'}2⊃'.'⎕WG'APLVersion'),' <0T <0T I'
      :If '\'=¯1↑Target
          Target,←1↓Source↑⍨-'\'⍳⍨⌽Source
      :EndIf
      :If 0=∆CopyFile((Source~'"')(Target~'"')),0
          11 ⎕SIGNAL⍨'Copy File error; rc=',⍕GetLastError
      :EndIf
      r←''
    ∇

    ∇ {Bool}←Delete Filename;Bool;i;a;∆DeleteFile;⎕ML;⎕IO
⍝ Delete a file
⍝ Note that the explicit result tells you whether the file to be deleted exists or not. _
⍝ It does <b>not</b> tell you whether the delete operation was successful or not. _
⍝ This is not a bug in "WinFile", it is what the underlying Windows API function _
⍝ is returning. If you need to be sure that the file in question really got deleted, _
⍝ use #.WinFile.DoesExistFile to find out.
⍝ Note that "Delete" does NOT supports wildcards. If it finds wildcard chars it _
⍝ throws an error.
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      '∆DeleteFile'⎕NA'I kernel32.C32|DeleteFile',('*A'⊃⍨1+12>{⍎⍵↑⍨¯1+⍵⍳'.'}2⊃'.'⎕WG'APLVersion'),' <0T'
      Filename←RavelEnclose Filename
      Filename←CorrectForwardSlash¨Filename
      Bool←1⍴⍨⍴Filename←Filename~¨'"'
      'Delete does not support wildcard chars (?*)'⎕SIGNAL 11/⍨∨/¨'?*'∘∊¨Filename
      :For i :In ⍳⍴Bool
          (i⊃Bool)←0≠∆DeleteFile Filename[i]
      :EndFor
    ∇

    ∇ R←{NewFlag}CheckPath Path;This;Volume;Path_2;Points;i;Rc;Hint;⎕ML;⎕IO
    ⍝ Returns a 1 if the path to be checked is fine. If the path does not exist but _
    ⍝ the left argument is "CREATE!", it will be created.
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      R←0
      Path←CorrectForwardSlash Path
      :If '\'=¯1↑Path
          Path←¯1↓Path
      :EndIf
      :If 1=DoesExistDir Path
          R←1 ⍝ Complete Path exists, get out!
      :Else
          NewFlag←{6::'' ⋄ Uppercase⍎⍵}'NewFlag'
          NewFlag←'CREATE!'≡NewFlag
          Points←+\'\'=Path
          i←2 ⍝ not 1, since we are under windows and Path is fully qualified!
          :Repeat
              Path_2←Path/⍨Points<i
              :If 0=DoesExistDir Path_2
              :AndIf NewFlag
                  :Trap 0
                      MkDir Path_2
                      R←1
                  :Else
                      11 ⎕SIGNAL⍨'Error during create directory; rc=',⎕EN
                  :EndTrap
              :Else
                  R←0
              :EndIf
          :Until (1+⌈/Points)<i←i+1
      :EndIf
    ∇

    ∇ R←{Type}DateOf Filenames;Rc;Hint;Length;WIN32_FIND_DATA;handle;Buffer;Attr;This;ok;∆FindFirstFile;∆FindNextFile;∆FindClose;∆FileTimeToLocalFileTime;∆FileTimeToSystemTime;⎕ML
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      ⍝ "Type" may be one of: "Creation Time", "Last Access", "Last Write" (default!), "All"
      :If 0=⎕NC'Type'
          Type←'Last Write' ⍝ establish the default
      :EndIf
      Filenames←RavelEnclose Filenames
      Filenames←CorrectForwardSlash¨Filenames
      WIN32_FIND_DATA←'{I4 {I4 I4} {I4 I4} {I4 I4} {I4 I4} {I4 I4} T[260] T[14]}'
      '∆FindFirstFile'⎕NA'I4 kernel32.C32|FindFirstFile',('*A'⊃⍨1+12>{⍎⍵↑⍨¯1+⍵⍳'.'}2⊃'.'⎕WG'APLVersion'),' <0T >',WIN32_FIND_DATA
      '∆FindNextFile'⎕NA'U4 kernel32.C32|FindNextFile',('*A'⊃⍨1+12>{⍎⍵↑⍨¯1+⍵⍳'.'}2⊃'.'⎕WG'APLVersion'),' I4 >',WIN32_FIND_DATA
      '∆FindClose'⎕NA'kernel32.C32|FindClose I4'
      '∆FileTimeToLocalFileTime'⎕NA'I4 kernel32.C32|FileTimeToLocalFileTime <{I4 I4} >{I4 I4}'
      '∆FileTimeToSystemTime'⎕NA'I4 kernel32.C32|FileTimeToSystemTime <{I4 I4} >{I2 I2 I2 I2 I2 I2 I2 I2}'
      Attr←''
      :For This :In Filenames
          (handle Buffer)←FindFirstFile This~'"'
          :If 0=handle
              R←¯1
              :Return
          :Else
              Attr,←⊂Buffer
              {}∆FindClose handle
          :EndIf
      :EndFor
      Attr←⊂[1]⊃Attr
      Length←⍴Type←Uppercase,Type
      Attr←Attr[2 3 4]
      :Select Type
      :Case Length↑'LAST WRITE'
          R←Filetime_to_TS¨3⊃Attr
      :Case Length↑'LAST ACCESS'
          R←Filetime_to_TS¨2⊃Attr
      :Case Length↑'CREATION TIME'
          R←Filetime_to_TS¨1⊃Attr
      :Case Length↑'ALL'
          R←Filetime_to_TS¨Attr
      :Else
          'Invalid left argument'⎕SIGNAL 13
      :EndSelect
      :If Type≢'ALL'
          :If 1=⍴,Filenames
              R←↑R
          :Else
              R←⊃R
          :EndIf
      :EndIf
    ∇

    ∇ R←{parms}Dir Path;⎕ML;⎕IO;allowed;Path1;parms2
    ⍝ List the contents of a given directory, by default the current one.
    ⍝ Passing "Recursive" as left argument to list all sub-directories, too.
    ⍝ Note that when "Recursive" is specified as left argument, any wildcard chars in _
    ⍝ the right argument do effect the result list only but not the the directories searched.
    ⍝ For example, this expression:
    ⍝ <pre>WinFile.Dir '*.svn'</pre>
    ⍝ returns a list with all directories matching the pattern, even if they are contained _
    ⍝ in a sub-folder "abc" of the current dir which obviously doesn't match the pattern.
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      parms←{6::'' ⋄ ⍎⍵}'parms'
      :If ~0∊⍴parms
          allowed←,⊂'recursive'
          'Invalid left argument'⎕SIGNAL(0∊⍴parms2←CheckParms parms allowed)/11
          'Invalid left argument'⎕SIGNAL(0∊⍴GetVarsFromParms parms2)/11
      :EndIf
      Path←Path~'"'
      Path←CorrectForwardSlash Path
      Path1←{⍵↓⍨1+-'\'⍳⍨⌽⍵}Path
      'Invalid syntax: wildcards (*?) are not allowed in folder names'⎕SIGNAL 11/⍨∨/'*?'∊Path1
      R←parms DirX Path
      R←R[;1]
    ∇

    ∇ R←{Parms}DirX Path;handle;next;ok;attrs;Buffer;it;WIN32_FIND_DATA;∆NOOF;Allowed;Bool;∆RECURSIVE;Trash;DirFlag;Buffer2;Rc;Hint;Data;ThisPath;Buffer3;Where;a;∆FILETIME;∆FileTimeToLocalFileTime;∆FileTimeToSystemTime;folders;more;rc;⎕IO;path2;U4;Path2;Mask;k;More;Block;⎕ML;this;DirList;Path1;name
         ⍝ List the contents of a given directory, by default the current one.
         ⍝ Passing "Recursive" as left argument to list all sub-directories, too.
         ⍝ By default, long names as well as short names together with file properties are _
         ⍝ returned but no timestamps. If you are in need for timestamps, specify _
         ⍝ ('FileTime' 1) as left argument. You can restrict the number of files returned _
         ⍝ by specifying ('NoOf' {anyNumber}).
         ⍝ Note that when a recursive scan is performed, any wildcard chars in the right _
         ⍝ argument do effect the result list only but not the directories searched.
         ⍝ For example, this expression:
         ⍝ <pre>WinFile.DirX '*.svn'</pre>
         ⍝ returns a list with all files matching the pattern, even if they are contained _
         ⍝ in a sub-folder "abc" of the current dir which obviously doesn't match the pattern.
         ⍝ For adressing the file attributes see (and use) the FA_* and/or COL_* fields.
         ⍝ An example extracting the "Last write date" and the directory flag:
         ⍝ #.WinFile.((DirX '*')[;COL_LastWriteDate,FA_DIRECTORY])
     
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      ∆NOOF←⌊/⍳0
      ∆RECURSIVE←0
      ∆FILETIME←0   ⍝ If you need a filetime, set this to 1; however, without FileTime, DirX is *much* faster!
      :If ~0∊⍴,Parms←{6::'' ⋄ ⍎⍵}'Parms'
          Allowed←'NoOf' 'Recursive' 'FileTime'
          Parms←CheckParms(Parms Allowed)
          :If 0∊⍴Parms
              'Invalid Parameters'⎕SIGNAL 11
          :EndIf
          Trash←GetVarsFromParms Parms
      :EndIf
      '∆FileTimeToLocalFileTime'⎕NA'I4 kernel32.C32|FileTimeToLocalFileTime <{I4 I4} >{I4 I4}'
      '∆FileTimeToSystemTime'⎕NA'I4 kernel32.C32|FileTimeToSystemTime <{I4 I4} >{I2 I2 I2 I2 I2 I2 I2 I2}'
      :If 3∨.≠⎕NC⊃'∆FindFirstFile' '∆FindNextFile' '∆FindClose'
          WIN32_FIND_DATA←'{I4 {I4 I4} {I4 I4} {I4 I4} {I4 I4} {I4 I4} T[260] T[14]}'
          ⎕SHADOW⊃'∆FindFirstFile' '∆FindNextFile' '∆FindClose'
          '∆FindFirstFile'⎕NA'I4 kernel32.C32|FindFirstFile',('*A'⊃⍨1+12>{⍎⍵↑⍨¯1+⍵⍳'.'}2⊃'.'⎕WG'APLVersion'),' <0T >',WIN32_FIND_DATA
          '∆FindNextFile'⎕NA'U4 kernel32.C32|FindNextFile',('*A'⊃⍨1+12>{⍎⍵↑⍨¯1+⍵⍳'.'}2⊃'.'⎕WG'APLVersion'),' I4 >',WIN32_FIND_DATA
          '∆FindClose'⎕NA'kernel32.C32|FindClose I4'
      :EndIf
      R←0 38⍴' '
      Path←Path~'"'
      Path←CorrectForwardSlash Path
      :If 0∊⍴Path
          Path←(Cd''),'\*'
      :EndIf
      (Path2 Mask)←{⍵{(⍵↓⍺)(⍵↑⍺)}1+-'\'⍳⍨⌽⍵}Path
      'Invalid syntax: wildcards (*?) are not allowed in folder names'⎕SIGNAL 11/⍨∨/'*?'∊Path2
      :If ∧/~'*?'∊Path
          Path,←{0∊⍴⍵:⍵ ⋄ ('\'≠¯1↑⍵)/'\'}Path
      :EndIf
      Path,←('\'=¯1↑Path)/'*'
      (handle Buffer)←FindFirstFile Path
      :If 0=handle
          :If ~':'∊Path
              Path←(Cd''),'\',Path
          :EndIf
          :If {∨/'*?'∊⍵:1 ⋄ DoesExistFile ⍵}(-2×'\*'≡¯2↑Path)↓Path
              (handle Buffer)←FindFirstFile(-2×'\*'≡¯2↑Path)↓Path
              :If 0=handle
                  :If ∆RECURSIVE
                      ok←∆FindClose handle
                      →∆Go
                  :Else
                      :Return
                  :EndIf
              :Else
                  →∆CarryOn
              :EndIf
          :EndIf
      :Else
     ∆CarryOn:
          Buffer←,⊂Buffer
          :If 0=⎕NC'∆NOOF'
              ∆NOOF←⌊⌊/⍳0
          :EndIf
          ⎕IO←0
          :Repeat
              (ok More Block)←ReadBlockX(handle 250 Path)
              :If 1=ok
                  :If ~0∊⍴Block
                      Buffer,←Block
                  :Else
                      :Leave
                  :EndIf
              :Else
                  . ⍝ deal with serious errors!
              :EndIf
          :Until 0
          ⎕EX'Block'
          ok←∆FindClose handle
          Buffer←⊃Buffer
          :If ∆FILETIME
              Buffer[;1]←Filetime_to_TS¨Buffer[;1]
              Buffer[;2]←Filetime_to_TS Each Buffer[;2] ⍝ Because this contains potentially many copies
              Buffer[;3]←Filetime_to_TS¨Buffer[;3]
          :Else
              Buffer[;1 2 3]←⊂7⍴0
          :EndIf
          Buffer[;4]←0(2*32)⊥⍉⊃Buffer[;4]            ⍝ combine size elements
          Buffer←⊂[0]Buffer
          (1⊃Buffer)←⊃1⊃Buffer
          (2⊃Buffer)←⊃2⊃Buffer
          (3⊃Buffer)←⊃3⊃Buffer
          Buffer/⍨←5≠⍳8                              ⍝ bin the reserved elements
          attrs←0⊃Buffer
          Buffer←Buffer[5 6 4 1 2 3]
          Bool←2=↑∘⍴∘⍴¨Buffer
          (Bool/Buffer)←⊂[1]¨Bool/Buffer
          Buffer←⍉⊃Buffer
          Buffer,←⍉attrs
          Buffer←Buffer[;(⍳6)],⊃Buffer[;6]
          Buffer[{⍵/⍳⍴⍵}8≥{⍵⍳'.'}¨Buffer[;0];1]←⊂''  ⍝ Reset 8-byte names where appropriate
          :If ∆NOOF≤↑⍴R←Buffer
              R←∆NOOF↑[0]R
              :Return
          :EndIf
     
     ∆Go:
          ⎕IO←0
          :If 0<∆RECURSIVE
              Path↓⍨←-2×'*/'≡¯2↑Path
              :If ∨/'*?'∊Path
                  (Path name)←SplitPath Path
                  name←'\',name
              :Else
                  name←''
              :EndIf
          :AndIf ~0∊⍴DirList←ListDirsOnly Path
              :For this :In DirList
                  :If 0<0⊃⍴Buffer←('Recursive' 1)('FileTime'∆FILETIME)DirX Path,this,name
                      Buffer←(~Buffer[;0]∊,¨'.' '..')⌿Buffer
                  :AndIf ~0∊0⊃⍴Buffer
                      Buffer[;0]←(this,'\')∘,¨Buffer[;0]
                  :EndIf
                  R⍪←Buffer
              :EndFor
          :EndIf
          :If 2=⍴⍴R
              :If ∆NOOF≤↑⍴R
                  R←∆NOOF↑[0]R
              :EndIf
              :If 0<1⊃⍴R
                  R←R[sort_av⍋⊃R[;0];]
              :EndIf
          :EndIf
      :EndIf
    ∇

    ∇ R←{NewFlag}DoesExistDir Pathes;buffer;∆PathIsDirectory;⎕IO;⎕ML
    ⍝ Returns a Boolean: 1=the directory exists, 0=otherwise
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      '∆PathIsDirectory'⎕NA'I Shlwapi.C32|PathIsDirectory',('*A'⊃⍨1+12>{⍎⍵↑⍨¯1+⍵⍳'.'}2⊃'.'⎕WG'APLVersion'),' <0T >I'
      Pathes←RavelEnclose Pathes
      Pathes←CorrectForwardSlash¨Pathes
      'Wildcard characters are not supported'⎕SIGNAL 11/⍨∨/¨'?*'∘∊¨Pathes
      R←0≠↑¨{∆PathIsDirectory ⍵ 0}¨Pathes~¨'"'
    ∇

    ∇ R←DoesExistFile Filenames;∆PathFileExists;⎕IO;⎕ML
    ⍝ Returns 1 if for every file in "Filenames" that does exist, otherwise 0. _
    ⍝ Note that if a file exists but is a directory, a 0 is returned.
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      '∆PathFileExists'⎕NA'I4 shlwapi.C32|PathFileExists',('*A'⊃⍨1+12>{⍎⍵↑⍨¯1+⍵⍳'.'}2⊃'.'⎕WG'APLVersion'),' <0T >I'
      :If 2=⍴⍴Filenames
          Filenames←⊂[2]Filenames
      :EndIf
      Filenames←RavelEnclose Filenames
      Filenames←CorrectForwardSlash¨Filenames
      'Wildcard characters are not supported'⎕SIGNAL 11/⍨∨/¨'?*'∘∊¨Filenames
      R←↑¨{∆PathFileExists ⍵ 0}¨Filenames~¨'"'
      (R/R)←~DoesExistDir R/Filenames
    ∇

    ∇ R←DoesExist pattern;∆PathFileExists;⎕IO;⎕ML
    ⍝ Returns 1 if "pattern" matches either a file or a directory.
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      '∆PathFileExists'⎕NA'I4 shlwapi.C32|PathFileExists',('*A'⊃⍨1+12>{⍎⍵↑⍨¯1+⍵⍳'.'}2⊃'.'⎕WG'APLVersion'),' <0T >I'
      :If 2=⍴⍴pattern
          pattern←⊂[2]pattern
      :EndIf
      'Wildcard characters are not supported'⎕SIGNAL 11/⍨∨/¨'?*'∘∊¨pattern
      pattern←RavelEnclose pattern
      pattern←CorrectForwardSlash¨pattern
      R←↑¨{∆PathFileExists ⍵ 0}¨pattern~¨'"'
    ∇

    ∇ R←GetAllDrives;Values;Drives;∆GetLogicalDriveStrings;⎕IO;⎕ML
    ⍝ Return a vtv with the names of all files, for example:  "C:\"
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      '∆GetLogicalDriveStrings'⎕NA'U4 KERNEL32.C32|GetLogicalDriveStrings',('*A'⊃⍨1+12>{⍎⍵↑⍨¯1+⍵⍳'.'}2⊃'.'⎕WG'APLVersion'),' U4 >T[]'
      Values←∆GetLogicalDriveStrings 255 255
      Drives←⊂(↑Values)↑(⎕IO+1)⊃Values
      R←((~(⎕UCS 0)=∊Drives)⊂∊Drives)
    ∇

    ∇ R←GetDriveAndType;AllDrives;Txt;Types;∆GetDriveType;⎕IO;⎕ML
     ⍝ Return a matrix with the names and the types of all files.
     ⍝ The number of rows is defined by the number of drives found.
     ⍝ "Types" may be somthing like "Fixed", "CD-ROM", "Removable", "Remote"
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      '∆GetDriveType'⎕NA'U4 KERNEL32.C32|GetDriveType',('*A'⊃⍨1+12>{⍎⍵↑⍨¯1+⍵⍳'.'}2⊃'.'⎕WG'APLVersion'),' <0T'
      Types←∆GetDriveType∘⊂¨AllDrives←GetAllDrives
      Txt←'Invalid Path' 'Removable' 'Fixed' 'Remote' 'CD-ROM' 'Ram-Disk'
      R←AllDrives,Types,[1.5](Txt,⊂'Unknown')[(0,⍨⍳⍴Txt)⍳Types]
    ∇

    ∇ R←{PrefixString}GetTempFileName PathName;VOID;Rc;Hint;∆GetTempFileName;⎕ML;⎕IO
      ⍝ Returns the name of an unused temporary filename. If "PathName" _
      ⍝ is empty, the default temp path is taken. This means you can _
      ⍝ overwrite this by specifying a path.
      ⍝ "PrefixString", if defined, is a leading string of the filename _
      ⍝ going to be generated. This is <b>not</b> the same as
      ⍝ <pre>'pref',GetTempFileName ''</pre>
      ⍝ because specified as left argument it is taken into account _
      ⍝ when the uniquness of the created filename is tested.
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      '∆GetTempFileName'⎕NA'I4 KERNEL32.C32|GetTempFileName',('*A'⊃⍨1+12>{⍎⍵↑⍨¯1+⍵⍳'.'}2⊃'.'⎕WG'APLVersion'),' <0T <0T I4 >0T'
      PrefixString←{0<⎕NC ⍵:⍎⍵ ⋄ ''}'PrefixString'
      PathName←CorrectForwardSlash PathName
      :If 0∊⍴PathName
          :Trap 0
              PathName←GetTempPath
          :Else
              11 ⎕SIGNAL⍨'Cannot get a temp path; rc=',⍕⎕EN
          :EndTrap
      :EndIf
      :Trap 0
          :If 0=Rc←'Create!'CheckPath PathName
              11 ⎕SIGNAL⍨'Error during "Create <',PathName,'>"; rc=',⍕GetLastError
          :Else
              R←2⊃∆GetTempFileName PathName PrefixString 0 260
              :If 0∊⍴,3⊃R
                  11 ⎕SIGNAL⍨'Error during "Get Temp Filename"; rc=',⍕GetLastError
              :EndIf
          :EndIf
      :Else
          ⎕DM ⎕SIGNAL ⎕EN
      :EndTrap
    ∇

    ∇ R←GetTempPath;Path;∆GetTempPath;⎕ML;⎕IO
    ⍝ Returns the name of the path to the temporary files on your system.
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      '∆GetTempPath'⎕NA'I4 KERNEL32.C32|GetTempPath',('*A'⊃⍨1+12>{⍎⍵↑⍨¯1+⍵⍳'.'}2⊃'.'⎕WG'APLVersion'),' I4 >T[]'
      Path←↑↑/∆GetTempPath 260 260
      :If ~0∊⍴Path
          R←Path
      :Else
          11 ⎕SIGNAL⍨'Problem getting Windows temp path!; rc=',⍕GetLastError
      :EndIf
    ∇

    ∇ R←IsDirEmpty Pathes;∆PathIsDirectoryEmpty;⎕ML;⎕IO
    ⍝ Returns 1 if empty, 0 if not and ¯1 if the directory could not be found
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      '∆PathIsDirectoryEmpty'⎕NA'I4 Shlwapi.C32|PathIsDirectoryEmpty',('*A'⊃⍨1+12>{⍎⍵↑⍨¯1+⍵⍳'.'}2⊃'.'⎕WG'APLVersion'),' <0T >I'
      Pathes←RavelEnclose Pathes
      :If 0∊R←↑¨{∆PathIsDirectoryEmpty ⍵ 0}¨Pathes~¨'"'
          ((~R)/R)←¯1×~DoesExistDir(~R)/Pathes
      :EndIf
    ∇

    ∇ R←Source YoungerThan Target;TS_1;TS_2;⎕ML;⎕IO
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
     ⍝ Compare the "last changed at" timestamp accordingly
      Source←CorrectForwardSlash Source
      Target←CorrectForwardSlash Target
      :Trap 0
          TS_1←('FileTime' 1)DirX Source
      :Else
          11 ⎕SIGNAL⍨{⎕ML←3 ⋄ 1↓∊⎕TC[2],¨⍵}⎕DM
      :EndTrap
      :Trap 0
          TS_2←('FileTime' 1)DirX Target
      :Else
          11 ⎕SIGNAL⍨{⎕ML←3 ⋄ 1↓∊⎕TC[2],¨⍵}⎕DM
      :EndTrap
      TS_1←6⊃TS_1[1;]
      TS_2←6⊃TS_2[1;]
      :If =/R←100⊥¨¯1↓¨TS_1 TS_2
          R←↑</¯1↑¨TS_1 TS_2
      :Else
          R←</R
      :EndIf
    ∇

    ∇ R←{Recursive}ListDirsOnly Path;Rc;ErrHint;Buffer;Buffer_2;This;Hint;⎕IO;Return;recursiveFlag;⎕ML
    ⍝ Returns a list with all directories in "Path". Can be asked for sub-directories by _
    ⍝ specifying "recursive" as left argument.
    ⍝ Wildcards are supported. Note that when use with "Recursive" as left argument the
    ⍝ wildcards only affect the resulting list of directories but NOT the directories searched.
    ⍝ Examples:
    ⍝ <pre>
    ⍝ ListDirsOnly '?.svn'          ⍝ Is there a dir ".svn" in the current dir?
    ⍝ ListDirsOnly '*.acre'         ⍝ List all dirs ending with ".acre" in current dir
    ⍝ ListDirsOnly 'ThisFolder'     ⍝ Assums "ThisFolder" is a dir & looks into it
    ⍝ ListDirsOnly 'ThisFolder\'    ⍝ Same as before
    ⍝ </pre>
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      R←''
      Recursive←{6::'' ⋄ Uppercase⍎⍵}'Recursive'
      recursiveFlag←Recursive≡'RECURSIVE'
      Path←CorrectForwardSlash Path
      :If 0∊⍴,Path
          Path←'*'
      :Else
          :If ∧/~'*?'∊Path
              Path,←'\'/⍨'\'≠¯1↑Path
          :EndIf
      :EndIf
      :If recursiveFlag
          Buffer←('Recursive' 1)DirX Path
      :Else
          Buffer←DirX Path
      :EndIf
      Buffer←(~Buffer[;1]∊,¨'..' '.')⌿Buffer
      R←Buffer[;1]⌿⍨Buffer[;FA_DIRECTORY]
    ∇

    ∇ {r}←MkDir Name;∆CreateDirectory;rc;⎕IO;⎕ML
    ⍝ Make a new directory
    ⍝ Result is always an empty vector.
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      'Invalid right argument: depth'⎕SIGNAL 11/⍨~0 1∊⍨≡Name
      'Invalid right argument: not char'⎕SIGNAL 11/⍨0=1↑0⍴Name
      '∆CreateDirectory'⎕NA'I4 KERNEL32.C32|CreateDirectory',('*A'⊃⍨1+12>{⍎⍵↑⍨¯1+⍵⍳'.'}2⊃'.'⎕WG'APLVersion'),' <0T <{I4 I4 I4}'
      Name←CorrectForwardSlash Name
      :If 1=≡Name←∊Name
      :AndIf ' '=1↑0⍴Name
          :If ~rc←∆CreateDirectory(Name~'"')(0 0 0)
              11 ⎕SIGNAL⍨'Error during create directory; rc=',⍕GetLastError
          :EndIf
      :Else
          11 ⎕SIGNAL⍨'Invalid argument'
      :EndIf
      r←''
    ∇

    ∇ {r}←Source MoveTo Target;CurrDir;Rc;Hint;SourceDrive;TargetDrive;Rc;Hint;rc;∆MoveFileEx;∆MoveFile;⎕IO;⎕ML
    ⍝ Copy "Source" to "Target".
    ⍝ In case of an error an exception is thrown.
    ⍝ The explicit result is always ''
    ⍝ Examples:
    ⍝ 'C:\readme.txt' #.WinFile.MoveTo 'D:\buffer\'
    ⍝ 'C:\readme.txt' #.WinFile.MoveTo 'D:\buffer\newname.txt'
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      'Invalid left argument'⎕SIGNAL 11/⍨0∊⍴Source
      'Invalid right argument'⎕SIGNAL 11/⍨0∊⍴Target
      '∆MoveFileEx'⎕NA'I kernel32.C32|MoveFileEx',('*A'⊃⍨1+12>{⍎⍵↑⍨¯1+⍵⍳'.'}2⊃'.'⎕WG'APLVersion'),' <0T <0T I4'
      '∆MoveFile'⎕NA'I Kernel32.C32|MoveFile',('*A'⊃⍨1+12>{⍎⍵↑⍨¯1+⍵⍳'.'}2⊃'.'⎕WG'APLVersion'),' <0T <0T'
      Source←CorrectForwardSlash Source
      Target←CorrectForwardSlash Target
      :Trap 0
          :If ∨/'*?'∊Source
              'Left argument must not contain either "?" or "*"'⎕SIGNAL 11
          :ElseIf ∨/'*?'∊Target
              'Right argument must not contain either "?" or "*"'⎕SIGNAL 11
          :Else
              CurrDir←Cd''
              SourceDrive←TargetDrive←''
              (('/'=Source)/Source)←'\'
              (('/'=Target)/Target)←'\'
              :If '\\'≢2↑Source
                  :If ':'∊Source
                      SourceDrive←Source↑⍨¯1+Source⍳':'
                  :Else
                      SourceDrive←CurrDir↑⍨¯1+CurrDir⍳':'
                      Source,⍨←CurrDir,'\'
                  :EndIf
                  SourceDrive←{('abcdefghijklmnopqrstuvwxyz',av)[(⎕A,av)⍳⍵]}SourceDrive
              :EndIf
              :If '\\'≢2↑Target
                  :If ':'∊Target
                      TargetDrive←Target↑⍨¯1+Target⍳':'
                  :Else
                      TargetDrive←CurrDir↑⍨¯1+CurrDir⍳':'
                      Target,⍨←CurrDir,'\'
                  :EndIf
                  :If '\'=¯1↑Target
                  :AndIf '\'≠¯1↑Source
                      Target,←1↓Source↑⍨-'\'⍳⍨⌽Source
                  :EndIf
                  TargetDrive←{('abcdefghijklmnopqrstuvwxyz',av)[(⎕A,av)⍳⍵]}TargetDrive
              :EndIf
              :If SourceDrive≢TargetDrive
              :AndIf '\'=¯1↑Source
                  '"MoveTo" cannot move directories on different drives'⎕SIGNAL 11
              :Else
                  :If 0=∆MoveFileEx((Source~'"')(Target~'"')),3       ⍝ 3=REPLACE_EXISTING (1) + COPY_ALLOWED (2)
                      ⎕EN ⎕SIGNAL⍨'MoveFile error; rc=',⍕GetLastError
                  :EndIf
              :EndIf
          :EndIf
      :Else
          ⎕EN ⎕SIGNAL⍨{⎕ML←3 ⋄ 1↓∊⎕TC[2],¨⍵}⎕DM
      :EndTrap
      r←''
    ∇

    ∇ {(r more)}←{Recursive}RmDir Name;RecursiveFlag;List;Hint;Rc;DirList;this;∆RemoveDirectory;bool;⎕ML;⎕IO
⍝ Removes a directory and it's contents. If the left argument is "Recursive"
⍝ then any files and sub-directories are deleted as well.
⍝ Since this operation might fail simply because another user is just looking _
⍝ into one of the directories going to be deleted, a boolean value is returned _
⍝ indicating success (0) or failure (positive error indicating the problem). _
⍝ As a second result "more" is returned.
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      'Invalid right argument: empty!'⎕SIGNAL 11/⍨0∊⍴Name
      'Invalid right argument: invalid depth!'⎕SIGNAL 11/⍨~0 1∊⍨≡Name
      '∆RemoveDirectory'⎕NA'I4 KERNEL32.C32|RemoveDirectory',('*A'⊃⍨1+12>{⍎⍵↑⍨¯1+⍵⍳'.'}2⊃'.'⎕WG'APLVersion'),' <0T'
      r←0 ⋄ more←''
      Recursive←{2=⎕NC ⍵:⍎⍵ ⋄ ''}'Recursive'
      RecursiveFlag←'RECURSIVE'≡Recursive←Uppercase Recursive
      :If ' '=1↑0⍴Name
          Name←CorrectForwardSlash Name
          :If DoesExistDir Name
              :If RecursiveFlag
                  :Trap 0
                      List←DirX Name,'\*.*'
                  :Else
                      11 ⎕SIGNAL⍨'Cannot get list from "',Name,'"'
                  :EndTrap
                  List←(~List[;1]∊,¨'.' '..')⌿List
                  List←List[;1]
                  :If ~0∊⍴,List←(⊂Name,'\'),¨List
                      :Trap 0
                          DirList←ListDirsOnly Name
                      :Else
                          11 ⎕SIGNAL'Cannot get list from "',Name,'"'
                      :EndTrap
                      DirList←(⊂Name,'\'),¨DirList
                      :If ~0∊⍴,DirList
                          :For this :In DirList
                              (r more)←Recursive RmDir this
                              :If 0<r
                                  :Return
                              :EndIf
                          :EndFor
                      :EndIf
                      :If ~0∊⍴∊List←List~DirList
                      :AndIf 0∊bool←Delete List
                          →0,r←1
                      :EndIf
                  :EndIf
              :EndIf
              :If ~∆RemoveDirectory⊂Name~'"'
                  r←{0<⍵:⍵ ⋄ 1}GetLastError
                  more←'Could not remove: ',Name
              :EndIf
          :Else
              more←'not found: "',Name,'"'
              r←1
          :EndIf
      :Else
          11 ⎕SIGNAL⍨'Invalid argument'
      :EndIf
    ∇

    ∇ R←ListFileAttributes;buffer
      :Access Public Shared
    ⍝ This function returns a matrix with all fields starting their names with "FA_".
    ⍝ These are used to index the result of ""DirX"" in order to get a particular _
    ⍝ file attrite. For example. in order to find out whether a file is hidden ar not:
    ⍝ (#.WinFile.DirX '*')[;#.WinFile.FA_HIDDEN]
    ⍝ The columns returned:
    ⍝ [;1] Name
    ⍝ [;2] Value (decimal)
    ⍝ [;3] Value (hex)
    ⍝ [;4] Remark
    ⍝ See also "ListDirXIndices"
      buffer←⊃⎕SRC ⎕THIS
      buffer←(∨/':Field Public Shared ReadOnly FA_'⍷buffer)⌿buffer
      buffer←¯1↓↓(¯1+1⍳⍨'FA_'⍷buffer[1;])↓[2]buffer
      R←{⍵↑⍨¯1+⍵⍳'←'}¨buffer
      buffer←{⍵↓⍨⍵⍳'⍝'}¨buffer
      buffer←(+/∧\' '=⊃buffer)↓¨buffer
      R←R,[1.5]{⍵↑⍨¯1+⍵⍳' '}¨buffer
      buffer←{⍵↓⍨⍵⍳' '}¨buffer
      R,←{⍵↑⍨¯1+⍵⍳' '}¨buffer
      buffer←{⍵↓⍨⍵⍳' '}¨buffer
      buffer←(+/∧\' '=⊃buffer)↓¨buffer
      R,←buffer↓¨⍨{-+/∧\' '=⌽⊃⍵}¨buffer
    ∇

    ∇ R←ListDirXIndices;buffer
      :Access Public Shared
    ⍝ This function returns a matrix with all indices useful to index the result of ""DirX"".
    ⍝ Note that these are the fields starting their names with "COL_"
    ⍝ Example to get the last write date
    ⍝ (#.WinFile.DirX '*')[;#.WinFile.FA_HIDDEN]
    ⍝ The columns returned:
    ⍝ [;1] Name
    ⍝ [;2] Value (decimal)
    ⍝ [;3] Value (hex)
    ⍝ [;4] Remark
    ⍝ See also "ListFileAttributes"
      buffer←⊃⎕SRC ⎕THIS
      buffer←(∨/':Field Public Shared ReadOnly COL_'⍷buffer)⌿buffer
      buffer←¯1↓↓(¯1+1⍳⍨'COL_'⍷buffer[1;])↓[2]buffer
      R←{⍵↑⍨¯1+⍵⍳'←'}¨buffer
      buffer←{⍵↓⍨1+⍵⍳'⍝'}¨buffer
      R←R,[1.5]buffer↓¨⍨{-+/∧\' '=⌽⊃⍵}¨buffer
    ∇

⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝ Internal stuff ⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝
    ∇ R←Uppercase What;uppercase;Upper;⎕IO;⎕ML;ind
      ⎕IO←1 ⋄ ⎕ML←3
      ind←1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80
      ind,←81 82 83 84 85 86 87 88 89 90 91 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61
      ind,←62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90
      ind,←91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114
      ind,←115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136
      ind,←137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158
      ind,←159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180
      ind,←181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202
      ind,←203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224
      ind,←225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246
      ind,←247 248 249 250 251 252 253 254 255 256
      Upper←av[ind]
      :If (≡What)∊0 1
          R←Upper[av⍳,What]
          R←(⍴What)⍴R
      :Else
          uppercase←{Upper[av⍳,⍵]}
          R←(⍴¨What)⍴¨uppercase¨,¨What
      :EndIf
    ∇

    ∇ r←Lowercase str;TOLOW;⎕IO;⎕ML
      ⎕IO←1 ⋄ ⎕ML←3
      'TOLOW'⎕NA'I4 USER32.C32|CharLowerA =0T'
      r←{0 1∊⍨≡⍵:{2=⍴⍴⍵:↑{2⊃TOLOW⊂⍵}¨↓⍵ ⋄ 2⊃TOLOW⊂⍵}⍵ ⋄ {2⊃TOLOW⊂⍵}¨⍵}str
    ∇

    ∇ rslt←FindFirstFile path;⎕IO
      ⎕IO←0 ⋄ ⎕ML←3
      :If ¯1=↑rslt←∆FindFirstFile path 0
          rslt←0 GetLastError
      :Else
          (1 6⊃rslt)←FindTrim(1 6⊃rslt)        ⍝ shorten the file name at the null delimiter
          (1 7⊃rslt)←FindTrim(1 7⊃rslt)        ⍝ and for the alternate name
          (1 0⊃rslt)←(32⍴2)⊤1 0⊃rslt
      :EndIf
    ∇

    ∇ rslt←Filetime_to_TS filetime;⎕IO;⎕ML
      ⎕IO←0 ⋄ ⎕ML←3
      rslt←∆FileTimeToLocalFileTime filetime 0
      :If 1≠↑rslt
      :OrIf 1≠↑rslt←∆FileTimeToSystemTime(1⊃rslt)0
          rslt←0 0                   ⍝ if either call failed then zero the time elements
      :EndIf
      rslt←1 1 0 1 1 1 1 1/1⊃rslt    ⍝ remove day of week
    ∇

      FindNextFile←{
          ⎕IO←0 ⋄ ⎕ML←3
          1≠↑rslt←∆FindNextFile ⍵ 0:0 GetLastError
          (1 6⊃rslt)←FindTrim(1 6⊃rslt)   ⍝ shorten the filename
          (1 7⊃rslt)←FindTrim(1 7⊃rslt)   ⍝ shorten the alternate name
          rslt
      }

      FindTrim←{
          ⎕IO←1 ⋄ ⎕ML←3
          ⍵↑⍨(⍵⍳↑av)-1
      }


    ∇ r←str Between what;⎕IO;⎕ML
      ⎕IO←1 ⋄ ⎕ML←3
      r←{⍵∨≠\⍵}what∊str
    ∇

    ∇ R←GetLastError;∆GetLastError;⎕ML;⎕IO
    ⍝ Sometimes this causes a DOMAIN ERROR. If that's the case, report the
    ⍝ circumstances to Dyalog: this is presumably caused by something that
    ⍝ is overwriting some memory. Areas of interest:
    ⍝ 1. Threads involved?
    ⍝ 2. Is a ⎕DL running in a thread?
    ⍝ 3. Which DLL was lately called?
      ⎕IO←1 ⋄ ⎕ML←3
      '∆GetLastError'⎕NA'I4 kernel32.C32|GetLastError' ⍝ DOMAIN ERROR? Read remarks!!
      R←∆GetLastError
    ∇

    ∇ (ok more block)←ReadBlockX(handle noOfRecords path);i;next;rc
      more←block←''
      ok←1 ⍝ success
      :For i :In ⍳noOfRecords
          (rc next)←∆FindNextFile handle 0
          :If 1=rc
              block,←⊂next
          :Else
              :If 0≠↑rc
              :AndIf ~(↑next)∊0 18
                  ok←11
                  more←'DirX error with: ',path
                  :Trap 0
                      {}∆FindClose handle
                  :EndTrap
                  ok←0 ⍝ failed
                  :Return
              :EndIf
              :Leave
          :EndIf
      :EndFor
      :If ~0∊⍴block
          block←⊃block
          block[;0]←↓,[0 1]⍉(32⍴2)⊤,[0.5]block[;0]
          block[;6]←{⍵↑¨⍨+/∧\(⎕UCS 0)≠⊃⍵}block[;6]
          block[;7]←{(↓⍵)↑¨⍨+/∧\(⎕UCS 0)≠⍵}{⍵⌽⍨+/∧\(⎕UCS 0)=⍵}⊃block[;7]
          block←↓block
      :EndIf
    ∇

    ∇ (ok more block)←ReadBlock(handle noOfRecords path);i;next;rc
      more←block←''
      ok←1 ⍝ success
      :For i :In ⍳noOfRecords
          (rc next)←∆FindNextFile handle 0
          :If 1=rc
              block,←⊂6⊃next
          :Else
              :If 0≠↑rc
              :AndIf ~(↑next)∊0 18
                  ok←11
                  more←'DirX error with: ',path
                  :Trap 0
                      {}∆FindClose handle
                  :EndTrap
                  ok←0 ⍝ failed
                  :Return
              :EndIf
              :Leave
          :EndIf
      :EndFor
      :If ~0∊⍴block
          block←(+/∧\(⎕UCS 0)≠⊃block)↑¨block
      :EndIf
    ∇

    ∇ r←(fns Each)array;unique;result
    ⍝ Fast "Each": applies "fns" on unique data tokens only
      unique←∪array
      result←fns¨unique
      r←(⍴array)⍴result[unique⍳array]
    ∇

    ∇ r←av;val
    ⍝ Holding this in a global variable would be faster indeed but
    ⍝ also not compatible with the Classic version
      val←0 8 10 13 32 12 6 7 27 9 9014 619 37 39 9082 9077 95 97 98 99 100 101 102 103 104 105 106 107 108 109
      val,←110 111 112 113 114 115 116 117 118 119 120 121 122 1 2 175 46 9068 48 49 50 51 52 53 54 55 56 57 3
      val,←164 165 36 163 162 8710 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90
      val,←4 5 253 183 127 9049 193 194 195 199 200 202 203 204 205 206 207 208 210 211 212 213 217 218 219 221
      val,←254 227 236 240 242 245 123 8364 125 8867 9015 168 192 196 197 198 9064 201 209 214 216 220 223 224
      val,←225 226 228 229 230 231 232 233 234 235 237 238 239 241 91 47 9023 92 9024 60 8804 61 8805 62 8800
      val,←8744 8743 45 43 247 215 63 8714 9076 126 8593 8595 9075 9675 42 8968 8970 8711 8728 40 8834 8835 8745
      val,←8746 8869 8868 124 59 44 9073 9074 9042 9035 9033 9021 8854 9055 9017 33 9045 9038 9067 9066 8801 8802
      val,←243 244 246 248 34 35 30 38 8217 9496 9488 9484 9492 9532 9472 9500 9508 9524 9516 9474 64 249 250 251
      val,←94 252 8216 8739 182 58 9079 191 161 8900 8592 8594 9053 41 93 31 160 167 9109 9054 9059
      r←⎕UCS val
    ∇

    ∇ r←sort_av;r1;r2;⎕IO
    ⍝ Character vector especially useful for sorting ANSI filenames.
    ⍝ Holding this in a global variable would be faster indeed but
    ⍝ also not compatible with the Classic version
      ⎕IO←0
      r1←⎕UCS 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90
      r2←⎕UCS 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122
      r←' ','.',r1,[-0.5]r2
    ∇

    RavelEnclose←    {(,∘⊂∘,⍣(1=≡,⍵))⍵}

    CorrectForwardSlash←{t←⍵ ⋄ ((t='/')/t)←'\' ⋄ t}
    
    ∇ r←CheckParms(parms allowed);depth;bool;buffer;⎕ML;⎕IO
    ⍝ "parms" is supposed to be a vector of two-item vectors like:
    ⍝ ('abc' 1)('Foo' 'hello')
    ⍝
      ⎕IO←1 ⋄ ⎕ML←3
      r←0 2⍴''                            ⍝ Initialyze the result
      :If 0∊⍴parms
          r←0 2⍴''
          :Return
      :EndIf
      :If 0∊⍴allowed
          'Invalid Parameter'⎕SIGNAL 11
      :EndIf
      :If 2=≡parms
      :AndIf 2=⍴parms
          parms←,⊂parms
      :EndIf
      :If 3>≡parms                    ⍝ Handle...
      :AndIf 2∨.≠↑∘⍴¨parms
          parms←,⊂parms               ⍝ ...Parms!
      :EndIf
      :If 0<+/bool←2<↑∘⍴¨parms
          (bool/parms)←{(↑⍵)(1↓⍵)}¨bool/parms
      :EndIf
      parms/⍨←0<↑∘⍴¨parms
      :If 2∨.≠↑∘⍴¨parms←,parms        ⍝ Check for proper structure.
          r←''                        ⍝ Structure invalid, complete faulty!
          :Return
      :EndIf
      :If 0∊⍴parms←(0<↑∘⍴¨parms)/parms
          r←0 2⍴''
          :Return
      :EndIf
      parms←↑,/parms                  ⍝ Make simple vector
      depth←≡parms                    ⍝ Save the Depth
      :If 0=depth
          r←0 2⍴''                    ⍝ Ready if empty: nothing right, nothing wrong...
          :Return
      :EndIf
      :If depth∊0 1                   ⍝ Jump if not simple
          parms←,⊂parms               ⍝ Enforce a nested vector
      :EndIf
      :If 0≠2|⍴parms←,parms           ⍝ Jump if even number of items
          r←''                        ⍝ Structur invalid, get out!
      :Else
          buffer←((⌊0.5×⍴parms),2)⍴parms ⍝ Build a matrix
          buffer[;1]←' '~¨⍨↓Uppercase⊃buffer[;1]
          :If ~0∊⍴allowed
              :If (|≡allowed)∊0 1     ⍝ Jump if Allowed is not simple
                  allowed←⊂allowed    ⍝ Enforce nested
              :EndIf
              allowed←,allowed        ⍝ Enforce a vector
              allowed←Uppercase allowed
              bool←buffer[;1]∊allowed ⍝ Column 1 must be member of Allowed
              :If 1∨.≠bool
                  ('Invalid Parameter: ',1↓↑,/' ',¨(~bool)/buffer[;1])⎕SIGNAL 11
              :EndIf
          :EndIf
          r←buffer                    ⍝ All is fine
      :EndIf
    ∇

    ∇ r←GetVarsFromParms parms;∆DUMMY;⎕IO;⎕ML
    ⍝ Establishes variables from "parms" which is supposed to be a vector of _
    ⍝ two-item vectors.
    ⍝ Example:
    ⍝ GetVarsFromParms  ('abc' 1)('Foo' 2)
    ⍝ creates two variables "∆ABC" and "∆FOO" with the values 1 and 2.
    ⍝ "r" is a vector of text vectors with the names of the variables created.
      ⎕IO←1 ⋄ ⎕ML←3
      parms⍪←'DUMMY'⍬                    ⍝ DUMMY is added to make the statement run if Parms is empty.
      parms[;1]←'∆',¨parms[;1]           ⍝ Add "∆" to avoid name conflicts.
      ⍎(↑,/' ',¨parms[;1]),'←parms[;2]'  ⍝ Create external parameters.
      r←¯1↓parms[;1]                     ⍝ ¯1↓ drops the DUMMY.
    ∇

:EndClass ⍝ WinFile