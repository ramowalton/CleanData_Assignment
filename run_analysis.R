library(reshape)
library(reshape2)

#function to download and unzip data
getData <- function() {
	fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
	download.file(fileUrl, destfile = "data.zip", method = "curl")
	unzip("data.zip")
}

#function to:
	#	1. combine test and training datasets
	#	2. rename columns based on variable names in features.txt
	#	3. extract only mean and std variables
	#	4. substitute activity label ID with description
cleanData <- function() {
	#load features to be used for column names
	features <- read.table("UCI HAR Dataset/features.txt")  
	
	#combine test datasets
	subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
	names(subject_test)[1] <- "Subject"						#set column name
	x_test <- read.table("UCI HAR Dataset/test/X_test.txt")
	features <- read.table("UCI HAR Dataset/features.txt")  
	for (i in 1:nrow(features)) {							#rename columns based on features.txt
		curCol <- paste("V", i, sep = "")					#derive column name in dataset
		newCol <- as.character(features[i,2])				#retrieve desired column name
		names(x_test)[names(x_test) == curCol] <- newCol	#replace column names
	}
	combined_test <- cbind(subject_test, x_test)
	y_test <- read.table("UCI HAR Dataset/test/y_test.txt")
	names(y_test)[1] <- "Activity"	#set column name
	combined_test <- cbind(combined_test, y_test)
	
	#combine training datasets
	subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
	names(subject_train)[1] <- "Subject"					#set column name
	x_train <- read.table("UCI HAR Dataset/train/X_train.txt")
	for (i in 1:nrow(features)) {							#rename columns based on features.txt
		curCol <- paste("V", i, sep = "")					#derive column name in dataset
		newCol <- as.character(features[i,2])				#retrieve desired column name
		names(x_train)[names(x_train) == curCol] <- newCol	#replace column names
	}
	combined_train <- cbind(subject_train, x_train)
	y_train <- read.table("UCI HAR Dataset/train/y_train.txt")
	names(y_train)[1] <- "Activity"							#set column name
	combined_train <- cbind(combined_train, y_train)
	
	#combine test and training datasets
	combined <- rbind(combined_test, combined_train)	
	
	#filter for mean and stddev variables only
	filteredCols <- c("Subject") 							#add first column manually
	matches <- grep("mean|Mean", names(combined))			#find any column referencing mean (accounting for differing case)
	matches <- c(matches, grep("std", names(combined)))		#find any column referencing std
	
	for (n in 1:length(names(combined))) {					#create list of desired columns (std and mean)
		if (n %in% matches) {
			filteredCols <- c(filteredCols, names(combined)[n])
		}			
	}
	filteredCols <- c(filteredCols, "Activity")				#add last column manually
	filtered <- combined[,filteredCols]						#filter dataset to only desired columns
	
	#add activity names
	filtered$Activity <- as.character(filtered$Activity)
	activities <- read.table("UCI HAR Dataset/activity_labels.txt") 
	names(activities) <- c("ID", "Activity")				#set column names
	for (a in 1:nrow(activities)) {
		#replace ID with descriptive activity
		filtered$Activity[filtered$Activity == as.character(activities[a,1])] <- as.character(activities[a,2])
	}
	
	#return clean dataset
	filtered
}

# function to create a tidy dataset comprising mean variables per activity and subject
createTidyData <- function() {
	#get tidy data
	getData()
	tidyData <-cleanData()
	
	#create average of each variable for each activity and each subject
	tidyMelt <- melt(tidyData, id=c("Subject", "Activity"), measure=names(tidyData)[2:(length(names(tidyData))-1)])
	activitySubjectMeanData <- dcast(tidyMelt, Activity + Subject ~ variable, mean)
	
	#write tidy data to file
	write.table(activitySubjectMeanData, "tidy.txt", row.names=FALSE)
}

# execute createTidyData function
createTidyData()