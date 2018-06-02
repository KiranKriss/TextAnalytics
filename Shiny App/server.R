
# setup code block
if (!require(udpipe)){install.packages("udpipe")}
if (!require(textrank)){install.packages("textrank")}
if (!require(lattice)){install.packages("lattice")}
if (!require(igraph)){install.packages("igraph")}
if (!require(ggraph)){install.packages("ggraph")}
if (!require(wordcloud)){install.packages("wordcloud")}

library(udpipe)
library(textrank)
library(lattice)
library(igraph)
library(ggraph)
library(ggplot2)
library(wordcloud)
library(stringr)

shinyServer(function(input, output) {

  # --------------------------------Second Tab (Annotate)---------------------------------
  Dataset <- reactive({
    
    if (is.null(input$TextFile)) {
      
                  return(NULL) } else{
      
      # lReadData = readLines("testdata.txt")
      ReadData = readLines(input$TextFile$datapath)
      ReadData  =  str_replace_all(ReadData, "<.*?>", "")
      str(ReadData)
      
      # load english model for annotation from working dir
      english_model = udpipe_load_model("./english-ud-2.0-170801.udpipe")
      
      # now annotate text dataset using ud_model above
      x <- udpipe_annotate(english_model, x = ReadData) 
      x <- as.data.frame(x)
      x1 <- select(x, -sentence)
      print(x1)
      # Display the Data in Shiny App
      output$annotate = renderDataTable({ 
        
        out = x1
        out   
        
      })
      #Calling Server Output function
      output$downloadData <- downloadHandler(
        filename = function() {
          paste(input$annotate, ".csv", sep = "")
        },
        content = function(file) {
          write.csv(datasetInput(), file, row.names = FALSE)
        })
      }
  })
  
  # ----------------------------------------Third Tab (Word Cloud)------------------------------------------
 
  
  all_nouns = x %>% subset(., upos %in% "NOUN"); all_nouns$token[1:20]
  top_nouns = txt_freq(all_nouns$lemma)
  
  all_verbs = x %>% subset(., upos %in% "VERB") 
  top_verbs = txt_freq(all_verbs$lemma)
  
  
  wordcloud_rep <- repeatable(wordcloud)
  
  output$WordCloud_Noun <- renderPlot({
    v <- terms()
    wordcloud_rep(words = top_nouns$key, 
                  freq = top_nouns$freq, 
                  min.freq = 2, 
                  max.words = 100,
                  random.order = FALSE, 
                  colors=brewer.pal(8, "Dark2"))
  })
  
  #Calling Server Output function
  output$WordCloud_Verb <- renderPlot({
    v <- terms()
    wordcloud_rep(words = top_verbs$key, 
                  freq = top_verbs$freq, 
                  min.freq = 2, 
                  max.words = 100,
                  random.order = FALSE, 
                  colors=brewer.pal(8, "Dark2"))
  })
  
  #----------------------------------------Fourth Tab (Cooccurence)--------------------------------------------
  nokia_colloc <- keywords_collocation(x = x,   # try ?keywords_collocation
                                       term = "token", 
                                       group = c("doc_id", "paragraph_id", "sentence_id"),
                                       ngram_max = 4)  # 0.42 secs
  
  str(nokia_colloc)
  nokia_colloc %>% head()
  
  # Sentence Co-occurrences for nouns or adj only
  cooc1 <- cooccurrence(   	
    x = subset(x, upos %in% input$variablePOS), 
    term = "lemma", 
    group = c("doc_id", "paragraph_id", "sentence_id")) 

  
  # general (non-sentence based) Co-occurrences
  cooc_gen <- cooccurrence(x = x$lemma, 
                                 relevant = x$upos %in% input$variablePOS)

  
  # Skipgram based Co-occurrences: How frequent do words follow one another within skipgram number of words
  cooc_skipgm <- cooccurrence(x = x$lemma, 
                                    relevant = x$upos %in% input$variablePOS, 
                                    skipgram = 4)
  

  wordnetwork <- head(cooc1, 50)
  wordnetwork <- igraph::graph_from_data_frame(wordnetwork) # needs edgelist in first 2 colms.
  
  #Calling Server Output function
  output$cooc_plot <- renderPlot({
  ggraph(wordnetwork, layout = "fr") +  
    
    geom_edge_link(aes(width = cooc, edge_alpha = cooc), edge_colour = "orange") +  
    geom_node_text(aes(label = name), col = "darkgreen", size = 4) +
    
    theme_graph(base_family = "Arial Narrow") +  
    theme(legend.position = "none") +
    
    labs(title = "Cooccurrences within 3 words distance", subtitle = input$variablePOS)
  })
  
})
