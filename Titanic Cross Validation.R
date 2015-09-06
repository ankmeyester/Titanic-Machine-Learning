#----------------Titanic Dataset - Logistic Regression - Ankush Laxmeshwar -----------------------
#-----------------Cross Validation across same data set-----------------------------------------

# Loading package to read the excel type data provided
require(xlsx)

#Setting working directory for this session to desired location
setwd("E:\\Analytics\\Titanic Dataset")

#Reading the Titanic Dataset from its location with full path name
mydata <- read.xlsx("E:\\Analytics\\Titanic Dataset\\Titanic.xls",sheetIndex = 1)

#Checking the data for datatypes
str(mydata)

#Checking the data for NAs
summary(mydata)

#Name,Ticket and Cabin are read as factors but they need to be character strings
mydata$Name <- as.character(mydata$Name)
mydata$Ticket <- as.character(mydata$Ticket)
mydata$Cabin <- as.character(mydata$Cabin)

#Replacing the NA values for Age variable with mean of all Age values
mydata$Age[is.na(mydata$Age)] <- mean(mydata$Age,na.rm=TRUE)

#Replacing the NA values for Embarked Variable with most embarked value which is S
mydata$Embarked[is.na(mydata$Embarked)] <- "S"

#Setting seed for reproducibility
set.seed(1234)

#Separating data into 70% training data and 30% testing data
separation <-  sort(sample(nrow(mydata), nrow(mydata)*0.7))
traindata <- mydata[separation,]
testdata <- mydata[-separation,]

#Fitting the model for logistic regression using all non character and non PassengerId variables
model <- glm(Survived ~ Pclass + Age + SibSp + Parch + Sex + Embarked, family = binomial(link = "logit"), data = traindata)

#Checking the model fitted
summary(model)

#We notice in the fitted model that Parch, SibSp and Embarked are statistically insignificant
#Hence we remove these variables and again fit the model
model2 <- glm(Survived ~ Pclass + Age + Sex, family = binomial(link = "logit"), data = traindata)

#Checking the new model fitted
summary(model2)

#Preparing the test data without the survived Column
tdat <- testdata[-2]

#Predicting the survivors on test data using the predict function with train data
surviveprob <- predict(model2,tdat,type = "response")

#Checking range of probabilities obtained
summary(surviveprob)

#Assigning the cutoff for survivors.
#Since more people died we will give greater tolerance to the non survivors (0)
#Hence we restrict survivors (1) to only the top 20 percentile (based of simple trial and error)
sresult <- ifelse(surviveprob>= quantile(surviveprob,0.8),1,0)

#Tabulate the actual survivors against predicted survivors
#We notice the Type 1 Error is more than Type 2 Error
#It's good that we predicted 4 survived but they actually died with contrast to
#50 being predicted as dead but actually surviving. In this we have lesser error
#of predicting chances of non survival
table(actual = testdata$Survived,predicted = sresult)

#Calculating the accuracy from the table by adding sensitivity and specificity and
#diving by total observations. The result is 79.85% which is favourable.
goodPredict <- sum(table(testdata$Survived,sresult)[1,1],table(testdata$Survived,sresult)[2,2])
totalValues <- sum(table(testdata$Survived,sresult))
(goodPredict/totalValues)*100

#Checking the Area under the ROC curve. Hence need pROC package
require(pROC)

#Binding the testdata with the predicted vector to compare sensitivity and specificity
#for the ROC curve
areaData <- cbind(testdata,sresult)

#Fitting the ROC curve and plotting it
#We see it biased to the upper left slightly. This shows the power of the predictor
#variables to discriminate and give us better response. The 79.85% reflects this.
roccurve <- roc(Survived~sresult,data=areaData)
plot(roccurve)

#The passengerId, actual survivors and predicted survivors are combined into one data frame
tdat2 <- cbind(PassengerId=tdat[,1],"Actual Survived" = testdata$Survived,"Predicted Survived" = sresult)

#The new result dataframe is written to an external CSV file
write.csv(tdat2,"result.csv",row.names = FALSE)

