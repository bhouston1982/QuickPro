# QuickPro
A cheap-and-dirty batch file for UWM's e-recs processing workflow

QuickPro is my attempt to streamline some of the ingest and processing tasks for the E-records workflow here at UW-Milwaukee. As our workflow is a bit of a kludge itself, it should be little surprise that the batch files is kludgy too. That said, it DOES work, and it DOES simply the process from the GUI-based version in the original, so that's something...

Tools and programs required for QuickPro full functionality include:

--Python v2.6+

--BagIt Python Library

--DROID (Digital Record Object Identification), UK National Archives

--EXIFTool

--Bulk Extractor 1.5.5 or later

--Bulk Rename Utility (CommandLine)

--FindDupe (available for download at http://www.sentex.net/~mwandel/finddupe/)

--XENA (National Archives of Australia digital preservation software)

Functionality of QuickPro is as follows:

1) User Enters Accession Directory (This is something that you have to do at the start of each session because I haven't figured out how to store variables. Plus side, I did figure out how to extract the accession number! So that's something)

2) User Enters Collection Title and Date of Transfer (first time only) (Fed into BagIt; can be altered to include additional BagIt fields for the BagInfo, but these seemed like the bare minimum needed)

3) BagIt creates a Bag for the records (including manifests and Bag Info)

4) DROID creates a profile from the input directory

5) DROID creates a searchable manifest from the input directory

6) DROID creates a comprehensive breakdown report from the input directory

7) Metadata (including manifests) are moved to a Metadata Folder inside the SIP

8) Access Copies are created from the Data folder; the Data folder is renamed "Originals"

9) Originals are set to Read-Only

10) FindDupe creates a list of exact duplicate files for the archivist's review; the archivist may delete directly from the list

11) Bulk Rename Utility iterates a set of rules to make file names a bit more file system-friendly

12) Bulk Extractor creates a features report to scan for PII

13) EXIFTool extracts embedded metadata from the files and saves to a CSV file within the metadata folder

14) XENA iterates through the files to create XENA objects inside a Preservation folder; these can be exported to open formats as needed


The intent of the batch is to automate the tedious parts of the e-records workflow, leaving archivists with the mental energy to work on the human-applicable parts, such as arrangement and description. Directory references are based on UWM internal folder structure for now but can easily be generalized as needed.


