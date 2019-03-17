server <- function(input,output){
  
  # mydata <- reactive({
  #   inFile <- input$data_selection_ui
  #   print(inFile)
  #   
  #   if (is.null(inFile))
  #     return(NULL)
  #   
  #   tbl <- fread(inFile)
  #   return(tbl)
  # })
  
  # myCorpus <- reactive({
  #   print('ccorpus')
  #   VCorpus(VectorSource(mydata$text))})
  # myCorpus <- VCorpus(VectorSource(mydata$text)
  
  # cleanCorpus <- reactive({clean_corpus(myCorpus)})
  # cleanCorpus <- clean_corpus(myCorpus)
  corpus_row <- reactive({input$corpus_num})
  top_freq <- reactive({term_frequency[min(input$TDM_slider):max(input$TDM_slider)]})
  
  output$table_ui <- renderTable(
    {
      df#mydata()
    },
    striped = TRUE, 
    hover = TRUE
  )
  # print(input$corpus_num)
  # corpus_row <- input$corpus_num
  output$pre_clean <- renderPrint({print(content(review_corpus[[corpus_row()]]))}) ## figure out why it isn't working. 
  output$post_clean <- renderPrint({print(content(cleaned_review_corpus[[corpus_row()]]))})
  output$TDM_freq <- renderPlot(barplot(top_freq(),col="darkorange",las=2))
  # output$unigram_wc1 <- renderPlot(wordcloud(word_freqs$term, word_freqs$num,min.freq=5,max.words=500,colors=brewer.pal(8, "Paired"), scale = c(4,.5)))
  output$unigram_wc2 <- renderWordcloud2(wordcloud2(word_freqs,shape = "diamond"))
  # output$bigram_wc1
  output$bigram_wc2 <- renderWordcloud2(wordcloud2(word_freqs_2,shape = "triangle"))
  # output$trigram_wc1
  output$trigram_wc2 <- renderWordcloud2(wordcloud2(word_freqs_3,shape = "cardioid"))
  
  output$tfidf_wc2 <- renderWordcloud2(wordcloud2(word_freqs_tf, shape='star'))
  
  output$bing_tbl <- renderTable(mytext_bing)
  output$bing_hist <- renderPlot(hist(sentiment_summary$review_sentiment, col = "lightblue", border = "black"))
  
  output$nrc_table <- renderTable(emotion_overall_summary)
  output$nrc_spider <- renderChartJSRadar(chartJSRadar(emotion_overall_summary))
  
}
