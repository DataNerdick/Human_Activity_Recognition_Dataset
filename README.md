# Human_Activity_Recognition_Dataset

The run_analysis file contains the Tidy Data extracted from the folowing dataset:
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
The original Raw data is a Human Activity Recognition database built from the recordings of 
30 subjects performing activities of daily living (ADL) while carrying a waist-mounted smartphone 
with embedded inertial sensors.

The goal of the project was to create a Tidy Dataset that satisfies the following criteria:

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement.
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names.
5. From the data set in step 4, creates a second, independent tidy data set with the 
average of each variable for each activity and each subject.

# Analysis
The first step was to read in Test and Train sets as well as Subject and Label Data to create one Data Table.
The features(variable names) where extracted and appended to test and train tables before the merged Data Table was created.

```R
temp <- tempfile()
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", temp)

#read the features
features <- read.table(unz(temp, "UCI HAR Dataset/features.txt"))
justFeatures <- features$V2 #extract only the features' names without numbers

#make test data frame
test <- read.table(unz(temp, "UCI HAR Dataset/test/X_test.txt"))
colnames(test) <- justFeatures #name the columns of the test
testLabels <- read.table(unz(temp, "UCI HAR Dataset/test/y_test.txt"))
names(testLabels) <- "activity"
testSubject <- read.table(unz(temp, "UCI HAR Dataset/test/subject_test.txt"))
names(testSubject) <- "volunteer"

testDF <- cbind(testSubject, testLabels, test)
```

![image](https://user-images.githubusercontent.com/16624729/44635962-d11a1400-a95d-11e8-9fc5-ad2f63364cb3.png)


```R
#make train data frame
train <- read.table(unz(temp, "UCI HAR Dataset/train/X_train.txt"))
colnames(train) <- justFeatures
trainLabels <- read.table(unz(temp, "UCI HAR Dataset/train/y_train.txt"))
names(trainLabels) <- "activity"
trainSubject <- read.table(unz(temp, "UCI HAR Dataset/train/subject_train.txt"))
names(trainSubject) <- "volunteer"

trainDF <- cbind(trainSubject, trainLabels, train)
unlink(temp)
```
![image](https://user-images.githubusercontent.com/16624729/44636013-0e7ea180-a95e-11e8-89d6-1fdab971938d.png)


```R
#create final data frame
theDF <- rbind(testDF, trainDF)
```
![image](https://user-images.githubusercontent.com/16624729/44636041-2d7d3380-a95e-11e8-85de-c2a46f6a069c.png)


The second step was to extract only the measurements on the mean and std
```R
library(tidyr)
#get only the columns with meand and std in them
neededCols <- grep("volunteer|activity|mean|std", names(theDF), value = T)
theData <- theDF[, neededCols]
```

The third step was to change the numbered activities to actual activity names

```R
#use mapValues from plyr package
result$activity <- plyr::mapvalues(theData$activity, from = c(1, 2, 3, 4, 5, 6),
                          to = c("walking", "walking_upstairs", "walking_downstairs", "sitting", "standing", "laying"))
```

The fourth step included changing the variables names to insure readibility.
```R
names(theData) <- gsub("\\()", "", names(theData))
names(theData) <- gsub("-", "", names(theData))
names(theData) <- gsub("^t", "time", names(theData))
names(theData) <- gsub("^f", "frequency", names(theData))
names(theData) <- gsub("Acc", "Accelerometer", names(theData))
names(theData) <- gsub("Gyro", "Gyroscope", names(theData))
names(theData) <- gsub("Mag", "Magnitude", names(theData))
names(theData) <- gsub("meanFreq", "meanfrequency", names(theData))
```
![image](https://user-images.githubusercontent.com/16624729/44636371-4686e400-a960-11e8-91b2-0cae477d803f.png)

The final step included grouping the data by volunteer and activity and calculating the average for each variable
which insured that there is one observation per row to satisfy tidy data princuple.

```R
theDataMean <- aggregate(theData[, 3:81], list(theData$volunteer, theData$activity), mean)
names(theDataMean) <- names(theData)
```

![image](https://user-images.githubusercontent.com/16624729/44636482-dcbb0a00-a960-11e8-992c-c2bc6e785e55.png)


### tidyData.csv is a tidy data set because:
1. Each variable forms a column.
2. Each observation forms a row.
3. Variable names are descriptive.

### Running the script
To run the Script, simpy copy it into R.
The following R packcages must be installed: dplyr, tidyr



