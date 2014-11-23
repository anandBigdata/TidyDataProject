## Create one R script called run_analysis.R that does the following:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names.
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

#=========================================================================================
# Install data.table and reshape2 packages if they don't exist. Load the packages for use.
#=========================================================================================
if (!require("data.table")) 
{
    message("Package data.table not found. Installing..")
    install.packages("data.table")  
}
library("data.table")

if (!require("reshape2")) 
{
    message("Package reshape2 not found. Installing..")
    install.packages("reshape2")    
}
library("reshape2")

#===============================================================================
# Load data into R
#===============================================================================

# Load activity labels and features data
activityLabels <- read.table("./data/UCI HAR Dataset/activity_labels.txt")[,2]
features <- read.table("./data/UCI HAR Dataset/features.txt")[,2]

# Load test data: X_test.txt, y_test.txt and subject_test.txt
xTest <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
yTest <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
subTest <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")

# Load train data: X_train.txt, y_train.txt and subject_train.txt
xTrain <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
yTrain <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
subTrain <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")

#===============================================================================
# Process Test data
#===============================================================================

#Create a subset of features that have have mean or std in their values
meanStdFeatures <-grep("mean|std",features)


#Set labels for xTest using features 
names(xTest) <- features               

#Subset the data frame to hold 
# only those columns that have mean or std features.
xTest <- xTest[,meanStdFeatures]      

#Append Activity Description to yTest
yTest <- cbind(yTest, activityLabels[yTest[,1]])

#Create labels/names for yTest
names(yTest) <- c("Activity_Id","Activity_Label")

#Create names for subTest
names(subTest) <- c("Subject")

#Column bind all test data sets
testData <- cbind(subTest,yTest,xTest)  


######################################
# Process Train Files
######################################

#Set labels for xTrain using features
names(xTrain) <- features                  

#Subset the data frame to hold 
# only those columns that have mean or std features.
xTrain <- xTrain[,meanStdFeatures]

##Append Activity Description to yTrain
yTrain <- cbind(yTrain, activityLabels[yTrain[,1]])

#Create labels/names for yTrain
names(yTrain) <- c("Activity_Id","Activity_Label")

#Create names for subTest
names(subTrain) <- c("Subject")

#Column bind all train data sets
trainData <- cbind(subTrain,yTrain,xTrain)  

# Merge test and training data to create one data set
trainTestData <- rbind(testData,trainData)

#Get a vector of names/labels excluding Subject, Activity_Id and Activity_Label
tidyDataLabels <- c("Subject","Activity_Id","Activity_Label")
functionLabels <- colnames(trainTestData)
functionLabels <- setdiff(functionLabels, tidyDataLabels)

#Melt data with id and measures
meltData <- melt(trainTestData,id=tidyDataLabels, measure.vars=functionLabels)

# Apply mean function to melt dataset using dcast function
tidyData <- dcast(meltData,Subject+Activity_Label ~ variable, mean)

#Write tidy data to file tidy_data.txt
write.table(tidyData, file="./data/tidy_data.txt",row.name=FALSE)
