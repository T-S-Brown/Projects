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


#-------------------------------------------#
# Retrieve the key price/volume data
#-------------------------------------------#

i <- 1
for(code in equity_codes) {
  
  data <- read_csv(url(paste0('https://www.alphavantage.co/query?function=TIME_SERIES_DAILY',
                              '&symbol=',code,
                              '&outputsize=full',
                              '&apikey=',av_key,'&datatype=csv')))
  
  data <- mutate(data, code = symbol)
  
  if(i == 1) {
    core_data <- data
  } else {
    core_data <- bind_rows(core_data, data)
  }
  
  
  print(paste0(code,' loaded    ', i, '/', length(equity_codes), ' complete'))
  
  i <- i + 1
}

print('Key price and volume data loaded')


