#-------------------------------------------#
# ML Equity Project
# Sourcing data
#
# Connects to APIs to download key data
# Performs first order data wrangling
#-------------------------------------------#


# Load the required packages
library(tidyverse)

# Set the working directory
setwd(dirname(rstudioapi::getSourceEditorContext()$path))


# Load the API keys
source('load_api_keys.R')


# Specify the vector of codes to analysis
equity_codes <- c("GSK.L", "LLOY.L", "LGEN.L")

# Extract the full or compact list
size <- 'full' # Valid options of 'full' or 'compact'


#-------------------------------------------#
# Retrieve the key price/volume data
#-------------------------------------------#

i <- 1
for(code in equity_codes) {
  
  data <- read_csv(url(paste0('https://www.alphavantage.co/query?function=TIME_SERIES_DAILY',
                              '&symbol=',code,
                              '&outputsize=', size,
                              '&apikey=',av_key,'&datatype=csv')))
  
  data <- mutate(data, code = code)
  
  if(i == 1) {
    core_data <- data
  } else {
    core_data <- bind_rows(core_data, data)
  }
  
  
  print(paste0(code,' loaded    ', i, '/', length(equity_codes), ' complete'))
  
  i <- i + 1
}

print('Key price and volume data loaded')


#-------------------------------------------#
# Derive the targets
#-------------------------------------------#

# Target 1 - Closing Price is at least 10% higher in 90 days and the price is sustained for 75% of the next month

core_data <- core_data %>%
  group_by(code) %>% 
  mutate(pct10_threshold = close * 0.1,
         diff = close - lead(close, 90),
         sustained = rollmean(diff, 30, fill = NA),
         target = ifelse(sustained > pct10_threshold, 1, 0)) %>% 
  ungroup()


if (!dir.exists(file.path(paste0(dirname(rstudioapi::getSourceEditorContext()$path),'/data)')))){
  dir.create('data')
}

key_price_data <- write_csv(core_data, )
    