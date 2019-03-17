library(shiny)
library(tm)
library(dplyr)
library(qdap)
library(wordcloud)
library(wordcloud2)
library(lubridate)
library(RWeka)
library(data.table)
library(tidyr)
library(radarchart)
library(sentimentr)
library(lexicon)
library(tidytext)
library(ggplot2)

### some things to note: 
### I haven't configured it to reselect things
### I can't use original wordcloud, only wordcloud2

####midea: what about have a whole dataset that is then filtered by day/time? 
######## reading files

# setwd("/Users/brennandonnell/grad_school/Data 902/pk/")
# df = fread("/Users/brennandonnell/grad_school/Data 902/pk/2019-02-08_apexlegends_rtweets.csv")
df = fread("2019-02-08_apexlegends_rtweets.csv")
# files = list.files(pattern="*apexlegends_rtweets.csv")
# l.df <- lapply(list.files(pattern="*apexlegends_rtweets.csv"), function(x) fread(x, stringsAsFactors = FALSE)) 
# this is how you read them all in. now select from a menu. 

####### CORPUS CREATION
review_corpus <- VCorpus(VectorSource(df$text))


clean_corpus <- function(corpus){
  cleaned_corpus <- tm_map(corpus, content_transformer(replace_abbreviation))
  cleaned_corpus <- tm_map(cleaned_corpus, content_transformer(tolower))
  cleaned_corpus <- tm_map(cleaned_corpus, removePunctuation)
  cleaned_corpus <- tm_map(cleaned_corpus, removeNumbers)
  cleaned_corpus <- tm_map(cleaned_corpus, removeWords, stopwords("english"))
  custom_stop_words <- c("apex", "playapex","respawn", "legends", "apexlegends", 'game', 'just', 
                         'can', 'make', 'will', 'apexnewsbr', 'get', 'now', 'playing', 'live', 'play', 'come',
                         'people', 'one') ### look later into how to define stop words
  cleaned_corpus <- tm_map(cleaned_corpus, removeWords, custom_stop_words)
  cleaned_corpus <- tm_map(cleaned_corpus, stripWhitespace)
  return(cleaned_corpus)
}


cleaned_review_corpus <- clean_corpus(review_corpus)

######### TDM

TDM_reviews <- TermDocumentMatrix(cleaned_review_corpus)


TDM_reviews_m <- as.matrix(TDM_reviews)


# Term Frequency
term_frequency <- rowSums(TDM_reviews_m)
# Sort term_frequency in descending order
term_frequency <- sort(term_frequency,dec=TRUE)
# View the top 20 most common words
top10 <- term_frequency[1:20]
# Plot a barchart of the 20 most common words
# barplot(top10,col="darkorange",las=2)

###### wordcloud

### unigram

word_freqs <- data.frame(term = names(term_frequency), num = term_frequency)

### bigram
tokenizer <- function(x)
  NGramTokenizer(x,Weka_control(min=2,max=2))
bigram_tdm <- TermDocumentMatrix(cleaned_review_corpus,control = list(tokenize=tokenizer))
bigram_tdm_m <- as.matrix(bigram_tdm)

# Term Frequency
term_frequency_2 <- rowSums(bigram_tdm_m)
# Sort term_frequency in descending order
term_frequency_2 <- sort(term_frequency_2,dec=TRUE)
############Word Cloud
# Create word_freqs
word_freqs_2 <- data.frame(term = names(term_frequency_2), num = term_frequency_2)
# Create a wordcloud for the values in word_freqs
# wordcloud(word_freqs$term, word_freqs$num,min.freq=5,max.words=500,colors=brewer.pal(8, "Paired"))

# wordcloud2(word_freqs_2,shape = "diamond")


#### trigram

tokenizer <- function(x)
  NGramTokenizer(x,Weka_control(min= 3,max=3))
trigram_tdm <- TermDocumentMatrix(cleaned_review_corpus,control = list(tokenize=tokenizer))
trigram_tdm_m <- as.matrix(trigram_tdm)

# Term Frequency
term_frequency_3 <- rowSums(trigram_tdm_m)
# Sort term_frequency in descending order
term_frequency_3 <- sort(term_frequency_3,dec=TRUE)
############Word Cloud
# Create word_freqs
word_freqs_3 <- data.frame(term = names(term_frequency_3), num = term_frequency_3)
# Create a wordcloud for the values in word_freqs
# wordcloud(word_freqs_3$term, word_freqs_3$num,min.freq=5,max.words=500,colors=brewer.pal(8, "Paired"))
# wordcloud2(word_freqs_3,shape = "diamond")


########### tf idf wordcloud
tfidf_tdm <- TermDocumentMatrix(cleaned_review_corpus,control=list(weighting=weightTfIdf))
tfidf_tdm_m <- as.matrix(tfidf_tdm)

# Term Frequency
term_frequency_tf <- rowSums(tfidf_tdm_m)
# Sort term_frequency in descending order
term_frequency_tf <- sort(term_frequency_tf,dec=TRUE)
############Word Cloud
# library(wordcloud)
# Create word_freqs
word_freqs_tf <- data.frame(term = names(term_frequency_tf), num = term_frequency_tf)
# Create a wordcloud for the values in word_freqs
# wordcloud(word_freqs_tf$term, word_freqs_tf$num,min.freq=5,random.order = FALSE, max.words=3000,colors=brewer.pal(8, "Paired"))
# wordcloud2(word_freqs_tf, shape='diamond')
#######Sentiment analysis: 

###afin

### bing
tidy_mytext <- tidy(TermDocumentMatrix(cleaned_review_corpus))
bing_lex <- get_sentiments("bing")
mytext_bing <- inner_join(tidy_mytext, bing_lex, by = c("term" = "word"))
mytext_bing$sentiment_n <- ifelse(mytext_bing$sentiment=="negative", -1, 1)
mytext_bing$sentiment_score <- mytext_bing$count*mytext_bing$sentiment_n


sentiment_summary <- mytext_bing %>%
  group_by(document) %>%
  summarize(review_sentiment = sum(sentiment_score)) %>%
  arrange(desc(review_sentiment))

####### nrc

nrc_lex <- get_sentiments("nrc")
mytext_nrc <- inner_join(tidy_mytext, nrc_lex, by = c("term" = "word"))
mytext_nrc_noposneg <- mytext_nrc[!(mytext_nrc$sentiment %in% c("positive","negative")),]
emotion_summary <- mytext_nrc_noposneg %>%
  group_by(document,sentiment) %>%
  summarize(review_sentiment = sum(count)) %>%
  arrange(desc(review_sentiment))

emotion_overall_summary <- mytext_nrc_noposneg %>%
  group_by(sentiment) %>%
  summarize(review_sentiment = sum(count)) %>%
  arrange(desc(review_sentiment))
