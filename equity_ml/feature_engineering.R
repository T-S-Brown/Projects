#-------------------------------------------#
# ML Equity Project
# Sourcing data
#
# Performs key feature engineering
#-------------------------------------------#


# Load the required packages
library(tidyverse)
library(forecast)
library(TTR)
library(tidyquant)


# Set the working directory
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

# Read in the source data
core_data <- read_csv('data/key_price_data.csv')

#-------------------------------------------#
# Derive the targets
#-------------------------------------------#

core_data <- core_data %>%
  group_by(code) %>% 
  arrange(code, timestamp) %>% 
  mutate(pct10_threshold = close * 0.1,
         pct20_threshold = close * 0.2,
         diff = close - lead(close, 120),
         sustained = rollmean(diff, 30, fill = NA),
         target1 = ifelse(sustained > pct10_threshold, 1, 0),
         target2 = ifelse(diff > pct10_threshold, 1, 0)) %>% 
  ungroup()


#-------------------------------------------#
# Derive key pricing features
#-------------------------------------------#

core_data <- core_data %>%
  group_by(code) %>% 
  mutate(d30_rmean = rollmean(close, 30, fill = NA),
         d90_rmean = rollmean(close, 90, fill = NA),
         pct_chg = close/lag(close, n = 1) - 1,
         d30p_rmean = rollmean(pct_chg, 30, fill = NA),
         d90p_rmean = rollmean(pct_chg, 90, fill = NA)) %>%
  ungroup()

#-------------------------------------------#
# Derive key technical indicators
#-------------------------------------------#

core_data <- core_data %>%
  group_by(code) %>% 
  mutate(spo = rollmean(close, 200, fill = NA) - rollmean(close, 30, fill = NA),
         epo = EMA(close, 200) - EMA(close, 30),
         tp = (high + low + close) / 3,
         aroon_up = aroon(close, 30)[,1],
         aroon_down = aroon(close, 30)[,2])

core_data = tq_mutate(data = core_data, select = c(high, low, close), mutate_fun = CCI)

