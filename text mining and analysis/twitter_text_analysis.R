#------------------------------#
# Text Mining and NLP
# Twitter
#
# Thomas Brown
#
#------------------------------#

# NOTE: THIS IS A WORK IN PROGRESS

# Load the required projects
library(twitteR)
library(tidytext)
library(tidyverse)
library(wordcloud)


# Setup the wd dynamically depending on what OS is being used

if (Sys.info()[['sysname']] == "Darwin") {
  setwd("/Users/Thomas/Dropbox/Data Science/Projects/text mining and analysis")
} else {
  setwd("C:/Users/Thomas/Dropbox/Data Science/Projects/text mining and analysis")
}


# Run the twitter authentication.
# This file is in the .gitignore for security reasons.
# It is simply a call to the function twitteR::setup_twitter_oauth()
source('twitter_setup.R')


# Choose a twitter account to read
user <- "realDonaldTrump"

# Extract the tweets and convert them to text
tweets <- userTimeline(user , n = 3000, includeRts = FALSE)

text <- tibble(sapply(tweets, function(col) {col$text}))
colnames(text) <- "tweets"


# Create a tweet id
text <- text %>%
  mutate(tweetID = 1:length(tweets))

# Tidy up the data
text_df <- text %>% 
  unnest_tokens(word, tweets)


# Remove stop words
key_tweet_data <- text_df %>% 
  anti_join(stop_words)

# For tweet specific
key_tweet_data <- key_tweet_data %>% 
  anti_join(tibble(word = c("https", "t.co")))

# Count the word frequencies
word_freqs <- key_tweet_data %>% 
  count(word, sort = TRUE)


# Plot a word cloud
wordcloud(word_freqs$word, word_freqs$n, max.words = 30)


