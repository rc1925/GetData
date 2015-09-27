library(dplyr)

##Two variables later used:
##1. to check if files used for this exercise are available in the working directory
##2. to import data
zip_name <- paste0(getwd(), "/getdata-projectfiles-UCI HAR Dataset.zip")
folder_name <- paste0(getwd(), "/UCI HAR Dataset") 



##If the folder containing the the files used during this exercise is available in the
##working directory, we will use that folder and rely on error messages thrown during
##the data import.
##If the folder is not available, we will look for the original .zip file.
##If the .zip file is not available, we download it.
if (file.exists(folder_name)) {
  
  } else if (file.exists(zip_name)) {
  
  unzip(zip_name)

  } else {
  
  temp <- tempfile()
  download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",temp)
  unzip(temp)
  unlink(temp)
  rm(temp)
  
}

#gsub(paste0(getwd(),"/UCI HAR Dataset"),"",list.files(paste0(getwd(),"/UCI HAR Dataset"), full.names=TRUE, recursive = TRUE))

activity_names <- read.table(paste0(folder_name, "/activity_labels.txt"), stringsAsFactors = FALSE)
names(activity_names) <- c("ActivityCode", "ActivityName")



col_names <- read.table(paste0(folder_name, "/features.txt"), stringsAsFactors = FALSE)
col_names <- col_names$V2
col_names[562:563] <- c("ActivityCode","Subject")
valid_col_names <- make.names(names=col_names, unique=TRUE, allow_ = TRUE)


df1 <- read.table(paste0(folder_name, "/test/X_test.txt"), stringsAsFactors = FALSE) %>%
      bind_cols(
        read.table(paste0(folder_name, "/test/y_test.txt"), stringsAsFactors = FALSE) %>%
        select(V562 = V1)
        ) %>%
      bind_cols(
        read.table(paste0(folder_name, "/test/subject_test.txt"), stringsAsFactors = FALSE) %>%
          select(V563 = V1)
      )

df2 <- read.table(paste0(folder_name, "/train/X_train.txt"), stringsAsFactors = FALSE) %>%
      bind_cols(
        read.table(paste0(folder_name, "/train/y_train.txt"), stringsAsFactors = FALSE) %>%
          select(V562 = V1)
        ) %>%
      bind_cols(
        read.table(paste0(folder_name, "/train/subject_train.txt"), stringsAsFactors = FALSE) %>%
          select(V563 = V1)
      )

df <- df1 %>% union(df2)

names(df) <- valid_col_names

rm(df1)
rm(df2)

final_dataset <- df %>%
              left_join(activity_names, by = "ActivityCode") %>%
              select(Subject, ActivityName, contains("mean.."), contains("std.."))

rm(df)

#glimpse(final_dataset)

write.table(final_dataset %>%
  group_by(Subject, ActivityName) %>%
  summarise_each(funs(mean)), "agg_dataset.txt",row.names = FALSE)
