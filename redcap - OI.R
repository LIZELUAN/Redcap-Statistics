library(tidyverse)
library(openxlsx)
### Original process of logging file
matchlist <- " key4oi| baseline| admin|上传文件 |删除文件 |1st |2nd |3rd |\\dth "
da <- read.csv("_Logging_2023-04-03_1156.csv") %>%        ###### ！！！修改文件名
  filter(str_detect(`时间.日期`,"2023-03")) %>%           #### ！！！修改时间
  filter(!(`用户名` %in% c("liujw9") | `行为` %in% c("管理/设计 ","数据导出 ","编辑角色 "))) %>%
  mutate(`行为` = str_replace_all(`行为`, matchlist, "")) %>%
  mutate(`行为` = str_replace_all(`行为`, "创建的|更新的", ""))

head(da)


# x <- "a\\n\\\\"
# writeLines(x)

  
# da$行为 <- gsub(" key4oi| baseline| admin|删除文件 |上传文件 |1st |2nd |3rd |4th |5th ", "", da$行为)


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


colnames(da)

### 每个医生 ###########
doc <- da %>%
  filter(`用户名` %in% c("xujc","dongzx","zhouyp")) 
check=list()
  
Doc_list <- c("董忠信","周亚鹏","林昱良","许季春","江琦庆","林云志","尹世杰","樊攀")
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
write.xlsx(new_list, file = "Redcap_OI_records_3月.xlsx",rowNames=F)    ##### !!! 修改输出的文件名
