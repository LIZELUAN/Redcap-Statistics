# Redcap-Statistics
This is a R script utilizing the logging file of the database to obtain:    
  1. the patient id list recorded by each user  
  2. the number of patient ids recorded by each user  
  3. the number of patient ids recorded by each group  
  4. the number of patient id (as well as patient name) recorded by each doctor.  

How to use:   
1. Set the environment:      
   ```   
   conda env create -f redcap_analysis.yaml
   conda activate redcap_statistics
   ```     
2. Run the analysis     
   ```
   ./redcap_OI.R [logging_file] [year-month]
   ./redcap_SD.R [logging_file] [year-month]
   ```
3. Output          
   The output file is an xlsx file containing the statistical information.
