@echo off
cls
type "H:\Departments\Archives\e-records workspace\quickprotitle.txt"
echo:
echo:
echo:
echo UWM Quick E-recs processing batch file
echo:
echo CC-BY-NC Brad Houston and the University of Wisconsin-Milwaukee, 2016

:entry

REM The entries in this section both dictate the  names of files and will propagate various metadata additions,
REM so it's important to set them correctly. All accession directories are assumed to be found in
REM H:\departments\archives\E-recs-unprocessed\, and the accession number is derived from the first 8
REM characters of the folder name. If a folder does not have an accession number, assign a dummy 
REM number for the sake of correct input.


REM If you are one of my lovely testers outside of UWM, you'll need to change 
REM the locations of the various programs and scripts being called here. In general, 
REM when you see a path along the lines of "H:\Departments\Archives\E-recs-unprocessed\
REM or "H:\Departments\Archives\E-records workspace", you should delete that and put in 
REM your own path to the file being called. (If you can put those programs in your SYSTEM 
REM path, even better... but I don't know how to do that).

echo:
echo Your directory name should have the format "YYYY-NNNColl". If it does not, please go change it so that it does. We'll wait here.
echo:
pause
echo:
set /p Dir=Please enter the name of the accession directory to be processed:  
set Acc=%DIR:~0,8%
set dropro=H:\Departments\Archives\E-recs-unprocessed\DROID%acc%.droid
set Dir=H:\Departments\Archives\E-recs-unprocessed\%DIR%
echo:
choice /M "You will process accession %ACC% in %DIR%. Is this right?"
if errorlevel 2 goto :entry

REM To do: Find a good way to allow the user to input a custom accession number without having to
REM change the folder title manually. (I may have to translate to a different language for this.)

echo:
choice /M "Do you want to Bag your files?"
if errorlevel 2 goto :droid



:BagIt

REM I am passing the BagIt Library metadata entries for the Source Organization and External Identifier
REM default tags in the BagIt specification. Additional standard tags may be added by adding arguments to the
REM Python command in line 50, below, and feeding it a variable set by user input. Arguments should take
REM the form of "--[tag-name] "%[variable]%". Remove the REM from the below line to add a sample input.

REM set /p Desc=Please enter a short description of the accession.


set /p src=Please enter the collection title: 
set /p DA=Please enter today's date in YYYYMMDD format: 
echo:
echo Bagging files with BagIt and creating checksums...

REM To Do: move all called components to the same directory as this batch file so I can eliminate the 
REM absolute paths. This should make universalizing this code a bit easier.

python H:\Departments\Archives\E-recs-unprocessed\bagit.py --source-organization "%src%" --external-identifier "%acc%" "%dir%"

cls
Echo Done!
Choice /M "Do you want to continue?"
if errorlevel 2 goto :bye

pause

:droid

REM This step creates a DROID profile in the e-records unprocessed base directory for the accession, from
REM which the DROID manifest and reports are derived. For now the profile sticks around in case the manifest
REM or report fails for some reason, but it may be appropriate to delete them once the code is working.
REM I've included a commented-out line of code after the report finishes if we want to add this.

echo:
Choice /M "Do you want to run a DROID profile?"
if errorlevel 2 goto :manifest
Echo Now running DROID file characterization...

call "H:\Departments\Archives\e-records workspace\Tools for Use\2.Ingest\DROID\droid-binary-6.2.1-bin\droid" -a "%DIR%" -R -p "H:\Departments\Archives\E-recs-unprocessed\DROID%acc%.droid"


Echo Done!
Choice /M "Do you want to continue?"
if errorlevel 2 goto :bye
pause

:manifest

REM This will create a CSV export of the DROID report, 1 line per file analyzed. There is an option to 
REM filter by key attributes (e.g. File Mismatch=True) but I haven't implemented it yet. For now, use 
REM the filter/sort capability within Excel.

mkdir "%DIR%\metadata"
echo:
Choice /m "Do you want to run a DROID manifest?"
if errorlevel 2 goto :reports
Echo Now running manifest...

call "H:\Departments\Archives\e-records workspace\Tools for Use\2.Ingest\DROID\droid-binary-6.2.1-bin\droid" -p "%dropro%" -e "%DIR%\metadata\DROID%acc%.csv"

cls
echo Done!
Choice /M "Do you want to continue?"
if errorlevel 2 goto :bye

:reports

REM This will create a PDF version of the Comprehensive Breakdown report that comes with the DROID software.
REM DROID can export the report in numerous formats, so depending on your need you can change the file
REM extension after the -r argument in line 114 and it will output to your format of choice (likely XML).

REM The below line will delete the DROID profile file if it detects a report has been generated.

REM if exist "%DIR%"\metadata\DROID%acc%.pdf del "%dropro%
echo:
choice /m "Do you want to run DROID reports?"
if errorlevel 2 goto :filecleanup
call "H:\Departments\Archives\e-records workspace\Tools for Use\2.Ingest\DROID\droid-binary-6.2.1-bin\droid" -p "%dropro%" -n "Comprehensive breakdown" -r "%DIR%\metadata\DROID%acc%.pdf" 

cls
echo Done!
Choice /M "Do you want to continue?"
if errorlevel 2 goto :bye
pause

:filecleanup

REM Note: if you wish to validate your Bag with the Bagger GUI or otherwise, you must do so
REM before this step. Once this step completes the tags will be moved to a different 
REM location, the data folder will be named "originals" and the Bag
REM will not validate.


cd "%dir%"
move *.txt .\metadata
rename data originals
if exist "%DIR%\Working Copies" goto :readonly
echo:
Echo Now creating working copies...
mkdir "%DIR%\Working Copies"
xcopy "%DIR%\originals" "%DIR%\Working Copies" /s /e 

pause

:readonly

REM Note: after this set the files and subfolders in your "Originals"
REM folder will be set read-only by the Windows file system. If you still need to
REM appraise and/or weed files in your originals, skip this step.

echo:

choice /m "Are originals ready to be set read-only?"
if errorlevel 2 goto :ReNamer
echo Now setting originals read-only....
cd originals
attrib /S /D +R

Choice /M "Do you want to continue?"
if errorlevel 2 goto :bye


:ReNamer
REM Testing Bulk Rename Utility in this spot. Will need to see how it does on files in the wild.

choice /m "Do you want to clean up file names?"
if errorlevel 2 goto :FindDupe
echo:
echo Now running through Bulk Renamer Utility...

"H:\Departments\Archives\e-records workspace\BRC_Unicode_32\BRC32.exe" /DIR:"%DIR%\Working Copies" /NOFOLDERS /RECURSIVE /STRIPSYMBOLS /TIDYDS /TRIM /REPLACECI:" ":"_" /NODUP /EXECUTE
"H:\Departments\Archives\e-records workspace\BRC_Unicode_32\BRC32.exe" /DIR:"%DIR%\Working Copies" /NOFILES /RECURSIVE /STRIPSYMBOLS /TIDYDS /TRIM /REPLACECI:" ":"_" /NODUP /EXECUTE
echo:
Choice /M "Do you want to continue?"
if errorlevel 2 goto :bye


:FindDupe
REM This tool will find and delete exact duplicates of files in the accession. Because 
REM I am still testing the effectiveness of this, I have set it to create a Batch file
REM and force the archivist to manually review the files the tool thinks are duplicates
REM before deleting them. If and when we become confident in the accuracy of the tool,
REM I will remove the -bat argument to delete directly. For "fuzzy hashing" or deleting 
REM copies of the same file in different formats, use the DupeGuru GUI.

choice /m "Do you want to find duplicate files?"
if errorlevel 2 goto :BulkExtractor
echo:
echo Now using FindDupe to find duplicate files. Review the batch file
echo created and then run it to delete the duplicates.
pause
"H:\Departments\Archives\e-records workspace\FindDupe.exe" -bat "%DIR%\metadata\%ACC%Deletes.bat" -del "%DIR%\Working Copies"
cls
echo Done! The list of duplicates is in the metadata folder as "20XX-YYDeletes.bat". (We'll open the directory for you.) 
echo: 
echo Edit the file as necessary, save, double click to run deletions, then rename the file "20XX-YYDeletes.txt" for documentation.

%systemRoot%\explorer.exe "%DIR%\metadata"

Choice /M "Do you want to continue?"
if errorlevel 2 goto :bye
:BulkExtractor

REM Bulk_Extractor in theory will identify and flag PII such as credit card numbers
REM and credit card numbers for possible restriction. The archivist will need to examine
REM the text files created by Bulk_Extractor and determine which, if any, files contain PII
REM or other sensitive information. This can be done either by viewing the text files in the
REM \BE_Reports directory, or by viewing the report.xml file in Bulk_Extractor Viewer
REM (Recommended for processors not familiar with the structure of a Bulk_Extractor report).
REM This step is most likely to change, as I work on making the tool return fewer false positives.

if exist "%DIR%\metadata\BE_Reports\report.xml" goto :EXIFTool
choice /m "Do you want to identify PII?"
if errorlevel 2 goto :EXIFTool
echo:
echo Now Running Bulk Extractor for PII....
"C:\Program Files (x86)\Bulk Extractor 1.5.5\64-bit\bulk_extractor" -R -o "%DIR%\metadata\BE_Reports" "%DIR%\Working Copies"

Choice /M "Do you want to continue?"
if errorlevel 2 goto :bye

:EXIFTool

REM This step will create a preservation.csv file in the accession's metadata folder,
REM from which the archivist will select descriptive fields to create the Access.xlsx
REM file. Because this step runs on the working copies of the materials, and is
REM intended to create a file navigation tool for patrons, it is STRONGLY
REM RECOMMENDED that manual arrangement/file renaming/deduplication be completed
REM before proceeding to this step.
cls
echo Next step is EXIFTool, which will create a file manifest of your working copies
echo directory. This will be used to create the descriptive data table
echo for patron use. It is strongly recommended that any manual changes to the files
echo be completed before continuing.
echo:
pause
echo:

choice /m "Do you want to run EXIFTool?"
if errorlevel 2 goto :XENA
echo:
echo Now Running EXIFTool for Preservation metadata....
"H:\Departments\Archives\e-records workspace\Tools for Use\3.Arrangement and Description\exiftool" "%dir%\working copies" -r -f -csv > "%DIR%\metadata\preservation%acc%.csv"

Choice /M "Do you want to continue?"
if errorlevel 2 goto :bye


:XENA

REM This step normalizes files into XENA packages, which are modified XML files. The
REM content can then be exported to preservation formats, such as ODT for text files.
REM If you would like to convert to different formats than the XENA default, or
REM you want to exclude a given folder from normalization, run the XENA GUI instead.
echo:
choice /m "Do you want to normalize files with XENA?"
if errorlevel 2 goto :bye
echo:
echo Now Normalizing Files with XENA...
cd "%DIR%\Working Copies"
for /r %%i in (*) do java -jar "H:\Departments\Archives\Admin\E-recs workflow tools\Step 4-Preservation\National Archives of Australia\Xena\xena.jar" au.gov.naa.digipres.xena.core.XenaMain -f "%%i" -p "H:\Departments\Archives\Admin\E-recs workflow tools\Step 4-Preservation\National Archives of Australia\Xena\plugins" -o "%DIR%\preservation"

:bye
echo:
Echo Done! Creating a Directory Tree and file list for you. Thanks for testing this batch file. Now opening SIP for your inspection...


REM The last output of this file is a pair of files, one that provides the file tree in ASCII
REM format, and one that provides a flat list of all folders. Both of these files can be 
REM imported into Excel one line per row, which may make it easier to convert the folder
REM list into component listings for the contents list.

tree %dir% /a > foldertree.txt
dir %dir% /a:d /b /s > folderlist.txt
cd H:\Departments\Archives\e-records workspace
%systemRoot%\explorer.exe "%DIR%"
