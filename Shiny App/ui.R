#---------------------------------------------------------------------#
#               Natural Language Processing using udpipe App                               #
#---------------------------------------------------------------------#


library("shiny")

shinyUI(
  fluidPage(
    tags$head(tags$style(
      HTML('
           #sidebar {
           background-color: #D3D3D3;
           }
           
           body, label, input, button, select { 
           font-family: "Arial";
           }
           #mainpanel {
           background-color: #DEB887;
           }
             body, label, input, button, select { 
               font-family: "Arial";
             }'  
           )
      )),
    titlePanel("Natural Language Processing"),
  
    sidebarLayout( 
      
      sidebarPanel( id = "sidebar",
        
              fileInput("TextFile", "Upload Text File"),
              checkboxGroupInput("variablePOS", "Select Parts of Speach:",
                                 c("Adjective" = "Adj",
                                   "Noun" = "N",
                                   "Proper Noun" = "PN",
                                   "Adverb" = "Adv",
                                   "Verb" = "V"), selected = c("Adj", "N", "PN")),
              tableOutput("data")
              
                 ),
    
    mainPanel( id = "mainpanel",
      
      tabsetPanel(type = "tabs",
                  
                      tabPanel("Overview",
                               h4(p("About this App")),
                               p("This app supports only text files. This app analyses the text in the uploaded file using UDPipe in R to give a bsic analysis of the provided text",align="justify"),
                               p("User would be able to select any of the universal parts of speech and the app would be able to analyse the co-occurances ",align="justify"),
                               p(span(strong("Annotated Data Tab:")), "This tab would display 100 rows of annonated data. User will have an option to download the data",align="justify"),
                               p(span(strong("Word Cloud Tab:")), "The app would showcase wordclouds of all the nouns & verbs occuring in the text file in this tab",align="justify"),
                               p(span(strong("Top 30 co-occurances:")), "Table displays top 30 co-occurances of words here ",align="justify"),
                               
                               br(),
                               h4('How to use this App'),
                               p('To use this app, click on', 
                                 span(strong("Upload text file")),
                                 'and uppload the text file. You can select the parts of speech for which you need analysis on')),
                      tabPanel("Annotated Data", 
                                   dataTableOutput('annotate'),
                               # Button
                               downloadButton("downloadData", "Download")),
                      
                      tabPanel("Word Cloud",
                               plotOutput('WordCloud_Noun'),
                               plotOutput('WordCloud_Verb')),

                      
                      tabPanel("Top 30 co-Occuraces",
                               dataTableOutput('cooc_plot'))
        
      ) # end of tabsetPanel
          )# end of main panel
            ) # end of sidebarLayout
              )  # end if fluidPage
                ) # end of UI
  


