#1. Merges the training and the test sets to create one data set.
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

#make train data frame
train <- read.table(unz(temp, "UCI HAR Dataset/train/X_train.txt"))
colnames(train) <- justFeatures
trainLabels <- read.table(unz(temp, "UCI HAR Dataset/train/y_train.txt"))
names(trainLabels) <- "activity"
trainSubject <- read.table(unz(temp, "UCI HAR Dataset/train/subject_train.txt"))
names(trainSubject) <- "volunteer"

trainDF <- cbind(trainSubject, trainLabels, train)

unlink(temp)

#create final data frame
theDF <- rbind(testDF, trainDF)

#2. Extracts only the measurements on the mean and standard deviation for each measurement.
library(tidyr)
#get only the columns with meand and std in them
neededCols <- grep("volunteer|activity|mean|std", names(theDF), value = T) #get the names of columns with mean and std
theData <- theDF[, neededCols]

#3. Uses descriptive activity names to name the activities in the data set

#use mapValues from plyr package
result$activity <- plyr::mapvalues(theData$activity, from = c(1, 2, 3, 4, 5, 6),
                          to = c("walking", "walking_upstairs", "walking_downstairs", "sitting", "standing", "laying"))

#4. Appropriately labels the data set with descriptive variable names.
names(theData) <- gsub("\\()", "", names(theData))
names(theData) <- gsub("-", "", names(theData))
names(theData) <- gsub("^t", "time", names(theData))
names(theData) <- gsub("^f", "frequency", names(theData))
names(theData) <- gsub("Acc", "Accelerometer", names(theData))
names(theData) <- gsub("Gyro", "Gyroscope", names(theData))
names(theData) <- gsub("Mag", "Magnitude", names(theData))
names(theData) <- gsub("meanFreq", "meanfrequency", names(theData))

#5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# aggregate all columns except first two, grouping by volunteer and activity, and applying the mean function  
theDataMean <- aggregate(theData[, 3:81], list(theData$volunteer, theData$activity), mean)
names(theDataMean) <- names(theData)

#6. Write the Tidy Data set into .csv and .txt file
write.csv(theDataMean, file = "tidyData.csv", row.names = FALSE)
write.table(theDataMean, file = "tidyData.txt", row.names = FALSE)

