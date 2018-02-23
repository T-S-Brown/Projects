#------------------------------#
# Credit Card Fraud Detection
# Thomas Brown
#------------------------------#
  
library(tidyverse)
library(caret)

set.seed(8549)

# Load into memory the source dataset from kaggles
source <- read.csv("/Users/Thomas/Downloads/creditcard.csv")


# Preview the data
head(source)

# Check the target split
table(source$Class)
sum(table(source$Class[2])) / length(source$Class)

# Perform a train/test split

data_index <- createDataPartition(source$Class, p = 0.8,
                                  list = FALSE, times = 1)

train <- source[data_index,]
test <- source[-data_index,]

rm(source)


# Data Preprocessing: Not Needed due to PCA



#---------------------------------------#
# Stage 1: Exploratory Data Analysis
#---------------------------------------#

# Descriptives

descriptives <- train %>%
    group_by(Class) %>% 
    summarise_all(mean)


# Quick and Dirty Evaluation of the principal components - correlation plot

correlations <- train %>% 
    summarize_all(funs(cor(., train$Class))) %>% 
    t()

colnames(correlations) <- "coef"

correlations <- data.frame(correlations)
correlations$feature <- rownames(correlations)
rownames(correlations) <- 1:nrow(correlations)

correlations <- mutate(correlations,
                       direction = case_when(
                           coef >= 0 ~ "Positive",
                           TRUE ~ "Negative"
                       ),
                       magnitude = abs(coef)) %>% 
    filter(feature != "Class")


correlations$feature <- factor(correlations$feature) %>%
    fct_reorder(correlations$magnitude)

exploratory_plot <- ggplot(data = correlations, aes(x = feature, y = magnitude, fill = direction)) +
    geom_bar(stat = "identity") +
    coord_flip() +
    labs(x = "Magnitude of Coefficient",
         y = "Feature",
         title = "Correlations with outcome",
         fill = "Coefficient Direction") +
    theme(plot.title = element_text(hjust = 0.5))

exploratory_plot

exploratory_plot + ylim(0, 1)



#---------------------------------------#
# Stage 2: Machine Learning Algorithm
#          construction
#---------------------------------------#

train$Class <- factor(train$Class)
levels(train$Class) <- c("Genuine", "Fraud")


# Model 1: Logistic Regression --------------------------------------------




# Set up a baseline model: Logistic Regression

# Set up 5 fold cross validation

tc <- trainControl("cv", 5,
                   savePredictions = TRUE,
                   classProbs = TRUE)


fit <- train(factor(Class) ~.,
             data      = train    ,
             method    = "glm"    ,
             family    = binomial ,
             trControl = tc,
             na.action = na.omit)

results <- round(summary(fit)$coefficients, 3)

predictions <- fit$pred

match <- predictions %>% 
    mutate(match = case_when(
        pred == obs ~ 1,
        TRUE ~ 0
    ))

# Correct Fraudulant Detections
fraud <- filter(match, obs == "Fraud")
sum(match$match) / length(match$match)
sum(fraud$match) / length(fraud$match)

# False Positive
fp <- filter(match, obs == "Genuine")
1 - (sum(fp$match) / length(fp$match))

predictions <- predict(fit, newdata = train)
actual <- train$Class

temp <- cbind(predictions, actual)
temp <- data.frame(temp) %>%
    mutate(match = case_when(
        predictions == actual ~ 1,
        TRUE ~ 0
    ))

sum(temp$match) / length(temp$match)

table(temp$predictions, temp$actual)

# Model 2: Random Forest --------------------------------------------------


# Model 3: Support Vector Machine -----------------------------------------


# Model 4: Gradient Boosting ----------------------------------------------


