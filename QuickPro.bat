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
set /p Dir=Please enter the name of the accession directory to be processed:  
set Acc=%DIR:~0,8%
set dropro=H:\Departments\Archives\E-recs-unprocessed\DROID%acc%.droid
set Dir=H:\Departments\Archives\E-recs-unprocessed\%DIR%
choice /M "You will process accession %ACC% in %DIR%. Is this right?"
if errorlevel 2 goto :entry
if exist "%dir%\bagit.txt" goto :droid
choice /M "Do you want to Bag your files?"
if errorlevel 2 goto :droid



:BagIt

set /p src=Please enter the collection title: 
set /p DA=Please enter today's date in YYYYMMDD format: 
echo:
echo Bagging files with BagIt and creating checksums...

python H:\Departments\Archives\E-recs-unprocessed\bagit.py --source-organization "%src%" --external-identifier "%acc%" "%dir%"

Echo Done!
Choice /M "Do you want to continue?"
if errorlevel 2 goto :bye

pause
:droid
echo:
if exist "H:\Departments\Archives\E-recs-unprocessed\DROID%acc%.droid" goto :manifest
Choice /M "Do you want to run a DROID profile?"
if errorlevel 2 goto :manifest
Echo Now running DROID file characterization...

call "H:\Departments\Archives\e-records workspace\Tools for Use\2.Ingest\DROID\droid-binary-6.2.1-bin\droid" -a "%DIR%" -R -p "H:\Departments\Archives\E-recs-unprocessed\DROID%acc%.droid"


Echo Done!
Choice /M "Do you want to continue?"
if errorlevel 2 goto :bye
pause

:manifest
echo:
if exist "%DIR%\metadata\DROID%acc%.csv" goto :reports
Choice /m "Do you want to run a DROID manifest?"
if errorlevel 2 goto :reports
Echo Now running manifest...
mkdir "%DIR%\metadata"
call "H:\Departments\Archives\e-records workspace\Tools for Use\2.Ingest\DROID\droid-binary-6.2.1-bin\droid" -p "%dropro%" -e "%DIR%\metadata\DROID%acc%.csv"

Choice /M "Do you want to continue?"
if errorlevel 2 goto :bye

:reports
if exist "%DIR%\metadata\DROID%acc%.pdf" goto :filecleanup
choice /m "Do you want to run DROID reports?"
if errorlevel 2 goto :filecleanup
call "H:\Departments\Archives\e-records workspace\Tools for Use\2.Ingest\DROID\droid-binary-6.2.1-bin\droid" -p "%dropro%" -n "Comprehensive breakdown" -r "%DIR%\metadata\DROID%acc%.pdf" 

Choice /M "Do you want to continue?"
if errorlevel 2 goto :bye
pause

:filecleanup
cd "%dir%"
move *.txt .\metadata
if exist "%DIR%\Working Copies" goto :EXIFTool
echo:
Echo Now creating working copies...
mkdir "%DIR%\Working Copies"
xcopy "%DIR%\data" "%DIR%\Working Copies" /s /e 

pause

:readonly
echo:
choice /m "Are originals ready to be set read-only?"
if errorlevel 2 goto :EXIFTool
echo Now setting originals read-only....
rename data originals
cd originals
attrib /S /D +R

Choice /M "Do you want to continue?"
if errorlevel 2 goto :bye
pause

:EXIFTool
if exist "%DIR%\metadata\preservation%DA%.csv" goto :BulkExtractor
choice /m "Do you want to run EXIFTool?"
if errorlevel 2 goto :BulkExtractor
echo:
echo Now Running EXIFTool for Preservation metadata....
"H:\Departments\Archives\e-records workspace\Tools for Use\3.Arrangement and Description\exiftool" "%dir%\working copies" -r -f -csv > "%DIR%\metadata\preservation%DA%.csv"

Choice /M "Do you want to continue?"
if errorlevel 2 goto :bye
pause

:BulkExtractor
if exist "%DIR%\metadata\BE_Reports\report.xml" goto :ReNamer
choice /m "Do you want to identify PII?"
if errorlevel 2 goto :ReNamer
echo:
echo Now Running Bulk Extractor for PII....
"C:\Program Files (x86)\Bulk Extractor 1.5.5\64-bit\bulk_extractor" -R -o "%DIR%\metadata\BE_Reports" "%DIR%\Working Copies"

Choice /M "Do you want to continue?"
if errorlevel 2 goto :bye
pause

:ReNamer
choice /m "Do you want to run ReNamer?"
if errorlevel 2 goto :XENA
echo:
echo Now adding to ReNamer...
echo ReNamer should have opened in Windows. Make any changes you need to and close it to move the batch file along. We'll be here when you get back!
"H:\Departments\Archives\e-records workspace\Tools for Use\3.Arrangement and Description\ReNamer\ReNamer" /preset "Basic_Cleaning" "%DIR%\Working Copies"
echo:
Choice /M "Do you want to continue?"
if errorlevel 2 goto :bye
pause

:XENA
choice /m "Do you want to normalize files with XENA?"
if errorlevel 2 goto :bye
echo:
echo Now Normalizing Files with XENA...
cd "%DIR%\Working Copies"
for /r %%i in (*) do java -jar "H:\Departments\Archives\Admin\E-recs workflow tools\Step 4-Preservation\National Archives of Australia\Xena\xena.jar" au.gov.naa.digipres.xena.core.XenaMain -f "%%i" -p "H:\Departments\Archives\Admin\E-recs workflow tools\Step 4-Preservation\National Archives of Australia\Xena\plugins" -o "%DIR%\preservation"

:bye
echo:
Echo Done! Thanks for testing this batch file. Now opening SIP for your inspection...
cd H:\Departments\Archives\e-records workspace
%systemRoot%\explorer.exe "%DIR%"
