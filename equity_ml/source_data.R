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

