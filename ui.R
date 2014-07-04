#### Shiny UI ####

shinyUI(
  navbarPage(title = "tRakt v0.1.6", inverse = TRUE, responsive = TRUE, fluid = TRUE,
    
    tabPanel("Main",
        progressInit(),
        
        h2(htmlOutput("show.name")),
        htmlOutput("show.overview"),
        # TODO: Make this default to device width somehow ¯\_(ツ)_/¯
        ggvisOutput(plot_id = "ggvis"),
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
             selectInput(inputId = "btn.scale.x", label = "Select timeline format:",
                         choices = btn.scale.x.choices, selected = "epnum"),
             checkboxInput(inputId = "btn.scale.y", label = "Scale Ratings 0 - 100%",
                           value = FALSE)     
          )
        ),
        hr(),   
        includeMarkdown("about.md")
    )       
  )
)
