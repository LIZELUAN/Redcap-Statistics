# Redcap-Statistics
This is a R script utilizing the logging file of the database to obtain:    
  1. the patient id list recorded by each user  
  2. the number of patient ids recorded by each user  
  3. the number of patient ids recorded by each group  
  4. the number of patient id (as well as patient name) recorded by each doctor.  

## How to use:   
 __*1. Set the environment in the Linux*__      
       ```   
       conda env create -f redcap_analysis.yaml
       conda activate redcap_statistics
       ```
                                          
 __*2. Run the analysis*__    
   For Redcap OI statistics:
   ```
   ./redcap_OI.R [logging_file] [year-month]
   ```
   For Redcap SD statistics:
   ```
   ./redcap_SD.R [logging_file] [year-month]     
   ```

                                    
   The example can be seen in the file  `run.sh`.
                                                             
 __*3. Output*__         
   The output file is an xlsx file containing the statistical information.

## Others     
The raw R script for analysis can been seen in the directory `redcap_before`.             
