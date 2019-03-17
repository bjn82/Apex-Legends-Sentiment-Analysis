ui <- navbarPage(title = 'Apex Legends', 
                 tabPanel(title = 'Readme', 
                          includeMarkdown("README.md")), 
                 # tabPanel(title = 'Exploration', 
                 #          sidebarLayout(
                 #            sidebarPanel(
                 #              selectInput(
                 #                inputId = 'data_selection_ui', 
                 #                label = 'Select date',
                 #                choices = list.files(pattern="*apexlegends_rtweets.csv"),
                 #                selected = '2019-02-08_apexlegends_rtweets.csv'
                 #                )
                 #            ), 
                 #            mainPanel(
                 #              tabsetPanel(
                 # tabPanel(title = 'Scrape tweets'), # this is a bonus idea
                 tabPanel(title = 'Dataframe', 
                          tableOutput(outputId = 'table_ui')),
                 tabPanel(title = 'Corpus', 
                          numericInput(inputId = 'corpus_num', label = 'Select row', value = 1, min = 1, max = length(review_corpus)),
                          splitLayout(
                            {#title = 'Pre-cleaning corpus'
                              h2('Pre-cleaning corpus')
                              verbatimTextOutput(outputId = 'pre_clean'#, inline=TRUE
                              )},
                            {#title = 'Post-cleaning corpus' 
                              h2('Post-cleaning corpus')
                              verbatimTextOutput(outputId = 'post_clean'#, inline=TRUE
                              )}
                          )), # this isn't wrapping the text, investigate it further. 
                 tabPanel(title = 'TDM', 
                          h2('Term Document Matrix term frequency'),
                          # cut off
                          plotOutput(outputId = 'TDM_freq'), 
                          sliderInput(
                            inputId = 'TDM_slider', 
                            label = 'Top terms in TDM', 
                            min = min(term_frequency), 
                            max = max(term_frequency), 
                            value = c(1,10))
                 ), 
                 tabPanel(title = 'Term Frequency Clouds', 
                          tabsetPanel(
                            tabPanel(title = 'unigram', h2('unigram'), 
                                     #        splitLayout(
                                     # plotOutput(outputId = 'unigram_wc1'), 
                                     wordcloud2Output(outputId = 'unigram_wc2')#)
                            ),
                            tabPanel(title = 'bigram', h2('bigram'), 
                                     wordcloud2Output(outputId = 'bigram_wc2')), 
                            tabPanel(title = 'trigram', h2("trigram"), 
                                     wordcloud2Output(outputId = 'trigram_wc2'))
                          )), #add more tabs here for sub tabs
                 tabPanel(title = 'TF-IDF word cloud',
                          h2('TD-IDF word cloud'),
                          wordcloud2Output(outputId = 'tfidf_wc2')),
                 tabPanel(title = 'Sentiment Analysis', 
                          h2('Sentiment Analysis'),
                          navlistPanel(
                            # tabPanel(title = 'Afinn'),
                            tabPanel(title = 'Bing', 
                                     splitLayout(
                                       tableOutput(outputId = 'bing_tbl'), 
                                       plotOutput(outputId = 'bing_hist')
                                     )),
                            # tabPanel(title = 'Loughran'),
                            tabPanel(title = 'NRC', 
                                     splitLayout(
                                       tableOutput(outputId = 'nrc_table'),
                                       chartJSRadarOutput(outputId = 'nrc_spider')
                                     ))                          
                          )
                 )#, #add more tabs here for lexicon
)
# )))
# 
# )