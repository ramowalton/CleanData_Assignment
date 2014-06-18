# README - Getting and Cleaning Data Course Project

## Summary
The run_analysis.R script creates a tidy dataset comprising test and training data sourced from:
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

## Overview of script
run_analysis.R includes several functions that are used in combination to create tidy.txt. A summary of each function is provided below:

### getData()
Downloads the data from the URL and unzips

### cleanData()
Performs the following functions to create an cleaned and consolidated dataset:

* Combines the test and training datasets using rbind and cbind
* Sets description names for the variables within the consolidated dataset (uses the column names from features.txt)
* Filters the consolidated data to only variables that reference mean or std. This step takes account of differences in case (e.g. mean vs. Mean)
* Replaces the activity lables with the activity descriptions included in activity_lables.txt

The function returns the cleaned dataset

### createTidyData()
Creates the final tidy dataset from the consolidated dataset created in cleanDat(). The function creates a dataset comprising the mean of each variable grouped by each activity and subject combination (using the melt and dcast functions of the reshape packages).