#### Shiny UI ####

shinyUI(
  navbarPage(title = "tRakt v0.1.9", inverse = TRUE, responsive = TRUE, fluid = TRUE,
    
    tabPanel("Main",
      progressInit(),
      h2(htmlOutput("show.name")),
      htmlOutput("show.overview"),
      # TODO: Make this default to device width somehow ¯\_(ツ)_/¯
      tabsetPanel(id = "mainPanel", selected = "tab.plot",
        tabPanel(title = "Plot", value = "tab.plot",
                  ggvisOutput(plot_id = "ggvis")
         ),
         tabPanel(title = "Data", value = "tab.data",
                  dataTableOutput(outputId = "table.episodes")
         )
      ),

      hr(),
      
      inputPanel(
        column(4,
          h3("Show Selection"),
          textInput(inputId = "show.query", label = "Enter the name of a show", value = "Firefly"),
          br(),
          actionButton(inputId = "get.show", label = "PLOTERIZZLE")
        ),
        column(4, offset = 1,
          h3("Plot Options"),
          selectInput(inputId = "btn.scale.x.variable", label = "Select timeline format:",
                      choices = btn.scale.x.choices, selected = "epnum"),
          selectInput(inputId = "btn.scale.y.variable", label = "Select target variable:",
                      choices = btn.scale.y.choices, selected = "rating"),
          checkboxInput(inputId = "btn.scale.y.range", label = "Scale Ratings 0 - 100%",
                        value = FALSE)     
        )
      ),
      hr(),   
      includeMarkdown("about.md")
    )       
  )
)
