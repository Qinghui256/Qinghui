This is the readme file for the replication package for 
“Sustainability or Greenwashing: Evidence from the Asset Market for Industrial Pollution”

Please open the “Replication code-20230154” file.
Included in the folder are two subfolders: Code and Data.

The “Code” folder includes 
(1)	A Stata do file “JF_replication” that generates all the tables and figures other than Figure 1.
a.	This do file contains comments to explain what table each section generates
(2)	Figure 1 is generated through Excel, and the data is provided in the Excel worksheet.
The Stata do file will use the data sets in the “Data” folder. 

Before running the do file, please:
•	Change the project folder directory to where you store the data
•	Change the output directory to where you store the output
•	Install the packages: coefplot, reghdfe, egenmore, mlogit, ppmlhdfe, outreg2, st0085_2 from http://www.stata-journal.com/software/sj14-2 (for command estpost), ftools (after installing; run ftools, compile), require, winsor2

The “Data” folder includes separate datasets for each of the tables and figures. 
Notes:
•	Tables 2 and 3 use the same source datasets
•	Tables 6 and 7, and Figure 3 use the same source datasets
•	Figure 2 and Table 4 use the same source datasets
•	Figure 5, Panel D uses the same source datasets as Table 11 Panel A.
Section 1 of the manuscript describes how the source data files are generated.





