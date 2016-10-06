###  Load libraries needed ##
library(data.table)


### Needed Variables for File paths ###
### These are all of the files to be worked on ###
workdir <- file.path(getwd(), "/Coursera/UCI HAR Dataset/")

featuresfile <- file.path(workdir, 'features.txt')
labelfile <- file.path(workdir, 'activity_labels.txt')
trainlabelfile <- file.path(workdir, 'train/y_train.txt')
trainsetfile <- file.path(workdir, 'train/x_train.txt')
trainsubjectfile <- file.path(workdir, 'train/subject_train.txt')
testlabelfile <- file.path(workdir, 'test/y_test.txt')
testsetfile <- file.path(workdir, 'test/x_test.txt')
testsubjectfile <- file.path(workdir, 'test/subject_test.txt')

### Load all the tables we will be working with

# Features Tables
allfeatures <- read.table(featuresfile)
all.trainfeatures <- read.table(trainsetfile)
all.testfeatures <- read.table(testsetfile)

#Activities Tables
activitylabels <- read.table(labelfile)
trainactivities <- read.table(trainlabelfile)
testactivities <- read.table(testlabelfile)

#Subject Tables
trainsubjects <- read.table(trainsubjectfile)
testsubjects <- read.table(testsubjectfile)


#### FEATURES  sTEPS 1-4 FOCUS ON FEATURES
### Only work with data we need to.  From assignment: Extracts only the measurements on the mean and standard deviation for each measurement. 
##Features file has two columns.  We are looking for any feature that has std or mean in column 2
stdmean.features <- grep("std|mean", allfeatures$V2)
### Step 2 Obtain the train and test std and mean feature sets.
stdmean.trainfeatures <- all.trainfeatures[,stdmean.features]
stdmean.testfeatures <- all.testfeatures[,stdmean.features]
### Step 3 Now combine the two data sets  
stdmean.traintestfeatures <- rbind(stdmean.trainfeatures, stdmean.testfeatures)
### Step 4 : Attach column names to the feature columns to tidy the data up. Now we have the combined set with column names.  We are done with features for now. 
#USE THIS LATER: stdmean.traintestfeatures
colnames(stdmean.traintestfeatures) <- allfeatures[stdmean.features, 2]

#### ACTIVITIES
### Step 5 : Combine the activity tables into one to get all activities
allactivities <- rbind(trainactivities, testactivities)
#Use the activitylabels table from above and attach them to a new allactivities$activity column to tidy the data using the factor allows us to work with vectors
# USE THIS LATER: allactivities
allactivities$activity <- factor(allactivities$V1, levels = activitylabels$V1, labels = activitylabels$V2)

#### SUBJECTS
### Step 6 Now work with the subject data and combine them into one set 
# USE THIS LATER: allsubjects
allsubjects <- rbind(trainsubjects, testsubjects)

#### ACTIVITIES AND SUBJECTS
### Step 7 Combine the activities and subjects
subjectsactivities <- cbind(allsubjects, allactivities$activity)
#Add descriptive column names per assignment "Appropriately labels the data set with descriptive variable names. "
# USE THIS IN STEP 8: subjectsactivities
colnames(subjectsactivities) <- c("subjectnumber", "activityname")


#### FEATURES + ACTIVITIES + SUBJECTS
### Step 8  We now have all features,  all subject and activites.  Now to pull it all together
subjectactivitiesfeatures <- cbind(subjectsactivities, stdmean.traintestfeatures)

####CREATE A NEW TIDY DATA SET FROM ABOVE IN STEP 8 (FEATURES + ACTIVITIES + SUBJECTS)
### Step 9 From assignment: From the data set in step 8, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
average.pervarperstudent <- aggregate(subjectactivitiesfeatures[,3:81], by = list(subjectactivitiesfeatures$subjectnumber, subjectactivitiesfeatures$activity), FUN = mean)

colnames(average.pervarperstudent)[1:2] <- c("subjectnumber", "activityname")

write.table(average.pervarperstudent, file="newtidyset.txt", row.names = FALSE)

