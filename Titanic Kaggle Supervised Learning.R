#----------------Titanic Dataset - Logistic Regression - Ankush Laxmeshwar -----------------------
#-----------------Kaggle Supervised Learning-----------------------------------------

#Setting working directory for this session to desired location
setwd("E:\\Analytics\\Titanic Dataset")

#Reading the Titanic Dataset from its location with full path name
traindata <- read.csv("E:\\Analytics\\Titanic Dataset\\train.csv",header = TRUE)
testdata <- read.csv("E:\\Analytics\\Titanic Dataset\\test.csv",header = TRUE)

#Checking the data for datatypes
str(traindata)

#Checking the data for NAs
summary(traindata)
summary(testdata)

#Name,Ticket and Cabin are read as factors but they need to be character strings
traindata$Name <- as.character(traindata$Name)
traindata$Ticket <- as.character(traindata$Ticket)
traindata$Cabin <- as.character(traindata$Cabin)

#Replacing the NA values for Age variable with mean of all Age values
traindata$Age[is.na(traindata$Age)] <- mean(traindata$Age,na.rm=TRUE)
testdata$Age[is.na(testdata$Age)] <- mean(testdata$Age,na.rm=TRUE)

traindata$Fare[is.na(traindata$Fare)] <- mean(traindata$Fare,na.rm=TRUE)
testdata$Fare[is.na(testdata$Fare)] <- mean(testdata$Fare,na.rm=TRUE)


#Replacing the NA values for Embarked Variable with most embarked value which is S

traindata$Embarked[traindata$Embarked==""] <- "S"
testdata$Embarked[testdata$Embarked==""] <- "S"

#Setting seed for reproducibility
set.seed(1234)

#Fitting the model for logistic regression using all non character and non PassengerId variables
model <- glm(Survived ~ Pclass + Age + SibSp + Parch + Sex + Embarked + Fare, family = binomial(link = "logit"), data = traindata)

#Checking the model fitted
summary(model)

#We notice in the fitted model that Parch, SibSp, Fare and Embarked are statistically insignificant
#Hence we remove these variables and again fit the model
model2 <- glm(Survived ~ Pclass + Age + Sex + SibSp, family = binomial(link = "logit"), data = traindata)

#Checking the new model fitted
summary(model2)

#Predicting the survivors on test data using the predict function with train data
surviveprob <- predict(model2,testdata,type = "response")

#Checking range of probabilities obtained
summary(surviveprob)

#Assigning the cutoff for survivors.
#Since more people died we will give greater tolerance to the non survivors (0)
#Hence we restrict survivors (1) to only the top 20 percentile (based of simple trial and error)
sresult <- ifelse(surviveprob>= quantile(surviveprob,0.8),1,0)

#The passengerId, actual survivors and predicted survivors are combined into one data frame
finaldata <- cbind(PassengerId=testdata[,1],Survived = sresult)

#The new result dataframe is written to an external CSV file
write.csv(finaldata,"TitanicResult.csv",row.names = FALSE)

