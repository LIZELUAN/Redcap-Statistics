oi_file="_Logging_2024-04-07_0742.csv"
./redcap_OI.R $oi_file 2023-12
./redcap_OI.R $oi_file 2024-01
./redcap_OI.R $oi_file 2024-02
./redcap_OI.R $oi_file 2024-03

sd_file="OISkeletalDysplasiaDatabaseWit_Logging_2024-04-07_0742.csv"
./redcap_SD.R $sd_file 2023-12
./redcap_SD.R $sd_file 2024-01
./redcap_SD.R $sd_file 2024-02
./redcap_SD.R $sd_file 2024-03


