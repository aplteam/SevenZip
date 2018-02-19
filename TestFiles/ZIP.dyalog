:Class ZIP
⍝ This class offers...
⍝ Author: Kai Jaeger ⋄ APL Team Ltd

    ∇ r←Version
      :Access Public Shared
      r←(⍕⎕THIS)'0.0.1' '2011-08-24'
    ∇

    ∇ {r}←{filename}CreateZipFile filelist;tn
      :Access Public Shared
    ⍝ ZIP one or more files into a ZIP file.
    ⍝ "filelist" is one of:
    ⍝ * A string starting with "file://" pointing to a file that contains a list of files _
    ⍝   to be zipped into the ZIP file.
    ⍝ * A vectors of text vectors each representing a file that is going to be compressed.
    ⍝ The optional left argument can be used to define the name of the zip file. If not _
    ⍝ specified a temporary filename is used,
    ⍝ The shy result is the name of the resulting ZIP file
    ⍝ Note that any existing ZIP file will be overwritten. See also "AppendToZipFile"
      :If ##.WinFile
     
      :EndIf
      tn←filename ⎕NCREATE 0
      (22↑80 75 5 6)⎕NAPPEND tn 83      ⍝ Create a ZIP file that declares itself as a ZIP file
      ⎕NUNTIE tn
     ⍝ Once the zip file is present,create an instance of the Shell COM...
      'SHAPP'⎕WC'OLEClient' 'Shell.Application'
     ⍝ ...get a handle to the files,here a folder and the zip archive,calling the NameSpace method...
      ADD←SHAPP.NameSpace⊂add_folder_name
      FILES←ADD.Items
      ZIP←SHAPP.NameSpace⊂zip_file_name
     ⍝ ...and finally have all files in that folder copied to the ZIP archive,
      ZIP.CopyHere FILES(4+16)
    ∇

:EndClass