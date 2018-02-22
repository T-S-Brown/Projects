#------------------------------#
# Credit Card Fraud Detection
# Thomas Brown
#------------------------------#
  
library(tidyverse)
library(caret)

set.seed(8589)

# Load into memory the source dataset from kaggles
source <- read_csv("/Users/Thomas/Downloads/creditcard.csv")


# Preview the data
head(source)

# Perform a train/test split

data_index <- createDataPartition(source$Class, p = 0.8,
                                  list = FALSE, times = 1)

train <- source[data_index,]
test <- source[-data_index,]

rm(source)


# Data Preprocessing



#---------------------------------------#
# Stage 1: Exploratory Data Analysis
#---------------------------------------#

# Descriptive Statistics

descriptives <- summarise_all(train, sd)

# Check class balance

# Quick and Dirty Evaluation of the principal components - correlation plot


#---------------------------------------#
# Stage 2: Machine Learning Algorithm
#          construction
#---------------------------------------#


# Set up a baseline model: Logistic Regression

# Set up 5 fold cross validation

tc <- trainControl("cv", 5, savePredictions = TRUE)


fit <- train(as.factor(Class) ~.,
             data      = train    ,
             method    = "glm"    ,
             family    = binomial ,
             trControl = tc,
             na.action = na.omit)

results <- round(summary(fit)$coefficients, 3)

