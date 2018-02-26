#------------------------------#
# Credit Card Fraud Detection
# Thomas Brown
#------------------------------#
  

# Load the required datasets and set seed for reproducibility
library(tidyverse)
library(caret)
library(PRROC)

set.seed(8549)

# Load into memory the source dataset from kaggle
# https://www.kaggle.com/mlg-ulb/creditcardfraud
source <- read.csv("D:/Data/creditcard.csv")

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

# Need to standardise time and amount. Others done via PCA
train$Time <- (train$Time - mean(train$Time)) / sd(train$Time)
train$Amount <- (train$Amount - mean(train$Amount)) / sd(train$Amount)

# Prep the test data to
test$Time <- (test$Time - mean(train$Time)) / sd(train$Time)
test$Amount <- (test$Amount - mean(train$Amount)) / sd(train$Amount)


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

test$Class <- factor(test$Class)
levels(test$Class) <- c("Genuine", "Fraud")



# Set up parallel computing for caret
#cores <- detectCores() - 1
#print(cores)
#cl <- makeCluster(cores)
#registerDoParallel(cl)


# Model 1: Logistic Regression --------------------------------------------

naive_model <- glm(Class ~ ., data = train, family = "binomial")


# Set up a baseline model: Logistic Regression

# Set up 5 fold cross validation

glm_tc <- trainControl("cv", 5,
                   savePredictions = TRUE,
                   classProbs = TRUE)


glm_mod <- train(Class ~ .,
             data      = train,
             method    = "glm",
             family    = binomial,
             trControl = glm_tc,
             na.action = na.omit)


# Save Results, coefficients and fitted probabilities

# COeficients
glm_coefs <- round(summary(glm_mod)$coefficients, 3)

# Fitted Probabilities
glm_probs <- glm_mod$finalModel$fitted.values


# Calculate AUPRC
glm0 <- glm_probs[as.numeric(train$Class) - 1 == 0]
glm1 <- glm_probs[as.numeric(train$Class) - 1 == 1]

glm_auprc <- pr.curve(glm1, glm0, curve = TRUE)
plot(glm_auprc)


# Model 2: Random Forest --------------------------------------------------

rf_tc <- trainControl("cv", 5,
                      savePredictions = TRUE,
                      classProbs = TRUE,
                      verboseIter = TRUE,
                      sampling = "down")

rf_grid <- expand.grid(mtry = 5)

rf_mod <- train(Class ~ .,
                data = train,
                method = "rf",
                metric = "Kappa",
                tuneGrid = rf_grid,
                trControl = rf_tc)

# Fitted Probabilities
rf_probs <- predict(rf_mod, newdata = train, type = "prob")[2]

# Calculate AUPRC
rf0 <- rf_probs[as.numeric(train$Class) - 1 == 0,]
rf1 <- rf_probs[as.numeric(train$Class) - 1 == 1,]


rf_auprc <- pr.curve(rf1, rf0, curve = TRUE)
plot(rf_auprc)

# Model 3: Support Vector Machine -----------------------------------------

svm_tc <- trainControl("cv", 5,
                       savePredictions = TRUE,
                       classProbs = TRUE,
                       verboseIter = TRUE,
                       sampling = "down",
                       search = "random")

svm_mod <- train(Class ~.,
                 data = train,
                 method = "svmRadial",
                 metric = "Kappa",
                 trControl = svm_tc)

# Fitted probabilities
svm_probs <- predict(svm_mod, newdata = train, type = "prob")[2]

svm0 <- svm_probs[as.numeric(train$Class) - 1 == 0,]
svm1 <- svm_probs[as.numeric(train$Class) - 1 == 1,]

svm_auprc <- pr.curve(svm1, svm0, curve = TRUE)
plot(svm_auprc)



# Model 4: Gradient Boosting ----------------------------------------------


boost_tc <- trainControl("cv", 5,
                         savePredictions = TRUE,
                         classProbs = TRUE,
                         verboseIter = TRUE,
                         sampling = "down",
                         search = "random")

boost_mod <- train(Class ~.,
                 data = train,
                 method = "adaboost",
                 metric = "Kappa",
                 trControl = boost_tc)

# Fitted probabilities
boost_probs <- predict(boost_mod, newdata = train, type = "prob")[2]

boost0 <- boost_probs[as.numeric(train$Class) - 1 == 0,]
boost1 <- boost_probs[as.numeric(train$Class) - 1 == 1,]

boost_auprc <- pr.curve(boost1, boost0, curve = TRUE)
plot(boost_auprc)




# Model Comparison --------------------------------------------------------


train_results <- resamples(list(glm = glm_mod,
                                rf = rf_mod,
                                svm = svm_mod,
                                boost = boost_mod))

summary(train_results)

bwplot(train_results)


glm_outcomes <- data.frame(confusionMatrix(data = glm_mod$pred$pred, reference = train$Class)$table) %>%
  mutate(model = "Logistic Regression")

rf_outcomes <- data.frame(confusionMatrix(data = rf_mod$pred$pred, reference = train$Class)$table) %>% 
  mutate(model = "Random Forest")

svm_outcomes <- data.frame(confusionMatrix(data = predict(svm_mod, newdata = train), reference = train$Class)$table) %>% 
  mutate(model = "Support Vector Machine")

boost_outcomes <- data.frame(confusionMatrix(data = predict(boost_mod, newdata = train), reference = train$Class)$table) %>% 
  mutate(model = "Gradient Boosting")


combined_results <- bind_rows(glm_outcomes, rf_outcomes, svm_outcomes, boost_outcomes)



ggplot(data = combined_results, aes(x = Reference, y = reorder(Prediction, desc(Prediction)), fill = Freq / sum(Freq))) +
  geom_tile() +
  geom_text(aes(label = Freq), col = "white") +
  labs(x = "Observed",
       y = "Predicted",
       fill = "Proportion",
       title = "Confusion Matrix") +
  theme(panel.background = element_blank(),
        plot.title = element_text(hjust = 0.5)) +
  facet_wrap(~model)

ggsave(filename = "C:/Users/Thomas/Dropbox/Data Science/Projects/credit_analysis/model_result_comparisons.png")
 

# Test Evaluation ---------------------------------------------------------


# From the confustion matrix, we are going to use Gradient Boosting

test_results <- predict(boost_mod, newdata = test, type = "raw")
test_probs <- predict(boost_mod, newdata = test, type = "prob")


# Confusion Matrix

test_values <- data.frame(confusionMatrix(data = test_results, reference = test$Class)$table)



ggplot(data = test_values, aes(x = Reference, y = reorder(Prediction, desc(Prediction)), fill = Freq / sum(Freq))) +
  geom_tile() +
  geom_text(aes(label = Freq), col = "white") +
  labs(x = "Observed",
       y = "Predicted",
       fill = "Proportion",
       title = "Confusion Matrix") +
  theme(panel.background = element_blank(),
        plot.title = element_text(hjust = 0.5))


