#!/data/lizeluan/miniconda3/bin/Rscript
######获取参数  文件名,查询日期, 并检查格式
args <- commandArgs(trailingOnly = TRUE)
if(length(args)!=2)
{
  stop("Not enough arguments. Please run as:\n./redcap_OI.R [logfile_name] [year-month]\n\nFor example: ./redcap_OI.R _Logging_2024-01-12_1257.csv 2023-10")
}

logfile_name <- args[1]   # e.g. "_Logging_2024-01-12_1257.csv"
if (!file_test("-f", logfile_name)) 
{
  stop("logfile not defined, or not correctly named.")
}

month <- args[2]    # e.g. "2023-10"
output_file_name <- paste0("Redcap_OI_records_",month,".xlsx")  # "Redcap_OI_records_2023-10.xlsx"

message(paste0("Now start statistical analysis on ",month," of ",logfile_name))

# 加载包
library(tidyverse)
library(openxlsx)

matchlist <- " key4oi| baseline| admin|上传文件 |1st |2nd |3rd |\\dth |创建的|更新的"
da <- read.csv(logfile_name, encoding="UTF-8", check.names = F)
colnames(da)[1] <- "时间.日期"
colnames(da)[4] <- "数据变更清单.或导出的字段"
da <- da %>%
  filter(str_detect(`时间.日期`,month)) %>%     
  filter(!(`用户名` %in% c("liujw9") | `行为` %in% c("管理/设计 ","数据导出 ","编辑角色 "))) %>%
  mutate(`行为` = str_replace_all(`行为`, matchlist, "")) %>%
  filter(!(str_detect(`行为`,"(^删除文件 记录 (\\d+) (doctor|nurse) record$)|(^Download uploaded document 记录 (\\d+)$)"))) %>%
  mutate(`数据变更清单.或导出的字段` = str_replace(`数据变更清单.或导出的字段`, "^(\\[)instance = (\\d+)(\\])(, )?", "")) %>%
  filter(!(str_detect(`数据变更清单.或导出的字段`,"(^$)|(^ddcd_complete = '\\d'$)|(^ddcd_8f4b18_complete = '\\d'$)")))

# view(da)

record_ids <- da %>%
  group_by(用户名,行为) %>%
  summarise() %>%
  ungroup()



#####每个用户记录病人数####
usr_num <- record_ids %>%
  group_by(用户名) %>%
  summarise(`记录病人id数`=n())

#####每个团队记录病人数######
group_list <- c("nurse","pt","doctor","Promis")
group_match <- str_c(group_list, collapse = "|")

group_num <- record_ids %>%
  mutate(Group=str_extract(`行为`, group_match)) %>%
  group_by(Group, `行为`) %>% summarise() %>% ungroup() %>%
  group_by(Group) %>%
  summarise(`记录病人id数`=n())
library(stringr)


# colnames(da)

### 每个医生 ###########
doc <- da %>%
  filter(`用户名` %in% c("xujc","dongzx","zhouyp")) 
check=list()
  
Doc_list <- c("董忠信","周亚鹏","林昱良","许季春","林云志","尹世杰","樊攀","田康康","张亦奋")
sumtable <- data.frame() 

for (i in Doc_list) {
detect_str <- paste("(?<=(recorder_discharge = '|doc_name = '|recorder1 = '))", i, "(?=')", sep="")

##### Find patient names recorded by this doctor
A <- doc %>%
  filter(str_detect(`数据变更清单.或导出的字段`, detect_str))


if (nrow(A) > 0) {
  check[[i]] <- A %>%
  mutate(Patient_name = str_extract_all(`数据变更清单.或导出的字段`, "(?<=(pa_name(\\d)?(_\\d)? = '))[\\p{Han}]+(?=')")) %>%
  group_by(`用户名`, `行为`, Patient_name) %>%
  summarise()

B <- doc %>%
  mutate(
  `Doctor_name`=str_extract(`数据变更清单.或导出的字段`, detect_str)
  ) %>%
  drop_na(Doctor_name) %>%
  group_by(Doctor_name, 行为) %>%
  summarise() %>% ungroup() %>%
  #####某医生记录病人数####
  group_by(Doctor_name) %>%
  summarise(`记录病人id数`=n())

sumtable <- rbind(sumtable,B)
}
}


##### Output ##############  
list_of_sheets <- list("record_ids" = record_ids, "usr_num" = usr_num, "group_num" = group_num, "each_doctor"=sumtable)
new_list <- c(list_of_sheets, check)
write.xlsx(new_list, file = output_file_name, rowNames=F)    ##### !!! 修改输出的文件名

message(paste0("Analysis finished. Output file: ",output_file_name))

