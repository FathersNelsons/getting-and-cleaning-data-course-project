# Getting and Cleaning Data Course Project

## Overview
This project was conducted for the Coursera class, "Getting and Cleaning Data" as part of the Data Science specialization through John's Hopkins University. In this project, raw data was gathered from [http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones] and cleaned to perform a simple analysis on the data.

## Contents
This repo includes:

* UCI HAR Dataset
  * This is a clone of the data we were working with in totality. It is required to run the script run_analysis.R
* .gitattributes and .gitignore
  * Simply git configuration files to let git know what to ignore
* CodeBook.docx and CodeBook.pdf
  * This document (in whichever format you wish) describes the variables for each record and their mapping. 
  * You may find the old code books in the UCI HAR Dataset folder.
* FinalDataSet.txt
  * This is the final file which was generated by run_analysis.R and submitted to Coursera for review.
* run_analysis.R
  * This is the script which assembles the raw data, prepares it, and runs a small analysis on it to meet the requirements of the course project. 

## Required
You must have the package dplyr installed in your environment to run the script which uses dplyr library a lot to perform the cleaning and analysis.

## Breakdown of run_analysis.R
### Part 1: Cleaning the Data
The first part of the script is all about pulling in and cleaning the raw data in the UCI HAR Dataset package. Upon cursory visual analysis, it could be seen the the following files of interest were space-delimited files, but the delimitations were not consistent in the number of spaces. That is, some delimitations were one space while others were two. 

* UCI HAR Dataset/test/X_test.txt
* UCI HAR Dataset/train/X_train.txt

So this first section (lines 1-13) simply read in the contents of the files, repair the delimitations so they are consistent, and write two clean temporary files for consumption.

```R
x_test_file <- readLines("UCI HAR Dataset/test/X_test.txt")
x_test_file <- gsub("  ", " ", x_test_file)
write(x_test_file, "x_test_ready.txt")

x_train_file <- readLines("UCI HAR Dataset/train/X_train.txt")
x_train_file <- gsub("  ", " ", x_train_file)
write(x_train_file, "x_train_ready.txt")
```

After that, the script reads the contents of the files into memory and drops the first column of each newly created data.tables. The reason it does so is because there is a leading space in the files which causes a null column to be written in each of the data.tables. Please also note that the original data.frames are converted into data.tables for easier manipulation and analysis. 

At line 38, the two data.tables are combined into one table. There is no attempt to maintain information on which list each record came from as it is not useful information nor is it a requirement to do so. At this point, we attempt to clean the variable names in the table. Since there is rich information already in the naming convention, we only try and simplify the syntax of the naming rather than the full content. Lines 41-46 change the names to lowercase, swap out hyphens with underscores, strip the "()"s, and replace the leading "t" and "f" in every variable name with "time_" or "frequency_" to make it more descriptive.

```R
names(x_data) <- tolower(names(x_data))
names(x_data) <- gsub("\\(\\)", "", names(x_data))
names(x_data) <- gsub("\\-", "_", names(x_data))
names(x_data) <- sub(pattern = "t", replacement = "time_", names(x_data))
names(x_data) <- sub(pattern = "f", replacement = "frequency_", names(x_data))
```

From the original documentation, we know that the y_test and y_train lists contain the activity identifiers for each corresponding set of x_data. With this information, we create a data.table with all ordered identifiers and then perform a left_join against a table created with the activity_labels.txt file. This allows us to relate the tables using the key "activity_id" and place the more descriptive text label in the working data.table, x_data, for every row. 

We then move on to use a similar method to pull in the subject identifier for each row, but we do not need to perform any joins as there is no relational data beyond the order of the subject_test.txt and subject_train.txt files. We simply cbind the resultant data.frame to the primary working data.table, x_data:

```R
subject_test  <- read.csv("UCI HAR Dataset/test/subject_test.txt", header = FALSE)
subject_train <- read.csv("UCI HAR Dataset/train/subject_train.txt", header = FALSE)
subjects      <- rbind(subject_test, subject_train)
colnames(subjects) <- c("subject")

x_data <- cbind(x_data, subjects)
```

### Part 2: Analyzing the Data
Now that the data has been satisfactorially cleansed and gathered, we use the dplyr library to assist with the analysis in the assignment: Find the averages of all variables for each subject and activity. As described in the brilliant article about this assignment posted in the forums, we find that this means we would like to find:

![320.png](https://thoughtfulbloke.files.wordpress.com/2015/09/320.png)

So we know that we want to group on subject and on activity to find averages for all variables which fall into the very center of that diagram. This is accomplished by using the group_by function from dplyr to group first on subject and then on activity. Once completed, we use another handy dplyr function called summarize_all which allows us to run some summary function on all variables in the table rather than individually listing out every variable. Finally, we rename the rows to be more descriptive and append "average_" to the front of all variables except the subject and activity columns, and then we write the table out to a file in the preferred format.

```R
subtivity <- group_by(x_data, subject, activity)
final_summary <- summarize_all(subtivity, mean)
names(final_summary)[-(1:2)] <- paste0("average_", names(final_summary)[-(1:2)])
write.table(final_summary, row.names = FALSE, file = "FinalDataSet.txt")
```

Finally, we perform some cleanup to save memory and delete our temporary files created earlier in the assignment. 

```R
rm(subtivity)
file.remove("x_test_ready.txt")
file.remove("x_train_ready.txt")
```

## Acknowledgements:
Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012