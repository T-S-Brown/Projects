#----------------------------------#
# Equity Analysis
# Loading Key Technical Data
#----------------------------------#

# Load the required packages
library(tidyverse)

# Set up the working directory
setwd("~/Dropbox/Data Science/Projects")

# API Keys
av_key <- '8GOVCO6D7NT5N3FR'


# Get the FTSE100 List
ftse100 <- read_csv('FTSE100CODES.csv') %>% select(Code) %>% filter(!is.na(Code))

    
#ftse100$Code[str_detect(ftse100$Code, '\\.$')]


av_symbol <- 'HL.L'
av_url <- paste0('https://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED&symbol=',
                 av_symbol,'&apikey=',av_key,'&datatype=csv&outputsize=full')

data <- read_csv(av_url)




