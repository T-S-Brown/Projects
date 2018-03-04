#------------------------------#
# Twitter Analysis
#------------------------------#

library(twitteR)
library(tidytext)
library(tidyverse)


if (Sys.info()[['sysname']] == "Darwin") {
  setwd("/Users/Thomas/Dropbox/Data Science/Projects/text mining and analysis")
} else {
  setwd("C:/Users/Thomas/Dropbox/Data Science/Projects/text mining and analysis")
}

source('twitter_setup.R')


user <- "realDonaldTrump"

tweets <- userTimeline(user , n = 3000, includeRts = FALSE)

text <- tibble(sapply(tweets, function(col) {col$text}))
colnames(text) <- "tweets"
