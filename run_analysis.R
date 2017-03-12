## run_analysis.R
## Author: Grayson Udstrand
library(dplyr)

## For x_test and x_train, cleanse the delimiters
## and create some temp files ready for reading.
x_test_file <- readLines("UCI HAR Dataset/test/X_test.txt")
x_test_file <- gsub("  ", " ", x_test_file)
write(x_test_file, "x_test_ready.txt")

x_train_file <- readLines("UCI HAR Dataset/train/X_train.txt")
x_train_file <- gsub("  ", " ", x_train_file)
write(x_train_file, "x_train_ready.txt")

## Read newly created files into memory
x_test  <- read.delim("x_test_ready.txt", header = FALSE, sep = " ")
x_train <- read.delim("x_train_ready.txt", header = FALSE, sep = " ")

## Convert to data.table for easier manipulation
x_test  <- tbl_df(x_test)
x_train <- tbl_df(x_train)

## Drop first column as it is null due to leading space in file
x_test  <- x_test[,-1]
x_train <- x_train[,-1]

## Pull features list into a vector and rename columns
features <- read.delim("UCI HAR Dataset/features.txt", sep = " ", header = FALSE)
feature_names <- as.character(features$V2)
colnames(x_test)  <- feature_names
colnames(x_train) <- feature_names

## Get only meaningful columns by name
x_test  <- x_test[,grepl("mean|std", colnames(x_test))]
x_train <- x_train[,grepl("mean|std", colnames(x_train))]

## Clean text variable names for test data
names(x_test) <- tolower(names(x_test))
names(x_test) <- gsub("\\(\\)", "", names(x_test))
names(x_test) <- sub(pattern = "t", replacement = "time-", names(x_test))
names(x_test) <- sub(pattern = "f", replacement = "frequency-", names(x_test))

## Clean text variable names for train data
names(x_train) <- tolower(names(x_train))
names(x_train) <- gsub("\\(\\)", "", names(x_train))
names(x_train) <- sub(pattern = "t", replacement = "time-", names(x_train))
names(x_train) <- sub(pattern = "f", replacement = "frequency-", names(x_train))

## Add type column prior to combination
x_test  <- mutate(x_test, type = "test")
x_train <- mutate(x_train, type = "train")

## Combine x_test and x_train into one data set
x_data <- rbind(x_test, x_train)
rm(x_test, x_train)

## Read in and combine y_test and y_train
y_test  <- read.csv("UCI HAR Dataset/test/y_test.txt", header = FALSE)
y_train <- read.csv("UCI HAR Dataset/train/y_train.txt", header = FALSE)
y_test  <- tbl_df(y_test)
y_train <- tbl_df(y_train)
y_data  <- rbind(y_test, y_train)
colnames(y_data) <- c("activity_id")

## Pull in and join on activity reference table and drop id
activity_ref <- read.delim("UCI HAR Dataset/activity_labels.txt", sep = " ", header = FALSE)
colnames(activity_ref) <- c("activity_id", "activity")
activities <- left_join(y_data, activity_ref, by = "activity_id")
activities <- activities[,-grepl("activity_id", colnames(activities))]

## Add to x_data
x_data <- cbind(x_data, activities)

## Pull in subject column as well
subject_test  <- read.csv("UCI HAR Dataset/test/subject_test.txt", header = FALSE)
subject_train <- read.csv("UCI HAR Dataset/train/subject_train.txt", header = FALSE)
subjects      <- rbind(subject_test, subject_train)
colnames(subjects) <- c("subject")

## Add to x_data
x_data <- cbind(x_data, subjects)

## Clean up
rm(activities, y_test, y_train, y_data, activity_ref,features, subject_test, subject_train, subjects)

##

