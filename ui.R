#### Shiny UI ####

shinyUI(
  navbarPage(title = "tRakt v0.1.10", inverse = TRUE, responsive = TRUE, fluid = TRUE,
    
    #### Main view ####
    tabPanel("Main", icon = icon("tasks"),
      progressInit(),
      
      #### Episode information ####
      h2(htmlOutput("show.name")),
      htmlOutput("show.overview"),
      
      # TODO: Make this default to device width somehow ¯\_(ツ)_/¯
      tabsetPanel(id = "mainPanel", selected = "tab.plot",
        tabPanel(title = "Plot", value = "tab.plot", icon = icon("bar-chart-o"),
                  ggvisOutput(plot_id = "ggvis")
         ),
         tabPanel(title = "Data", value = "tab.data", icon = icon("table"),
                  dataTableOutput(outputId = "table.episodes")
         )
      ),

      hr(),
      
      #### Control panel ####
      inputPanel(
        column(4,
          h3(icon("search"), "Show Selection"),
          textInput(inputId = "show.query", label = "Enter the name of a show", value = "Firefly"),
          br(),
          actionButton(inputId = "get.show", label = "PLOTERIZZLE", icon = icon("play"))
        ),
        column(4, offset = 1,
          h3( icon("cogs"), "Plot Options"), 
          selectInput(inputId = "btn.scale.x.variable", label = "Select timeline format:",
                      choices = btn.scale.x.choices, selected = "epnum"),
          selectInput(inputId = "btn.scale.y.variable", label = "Select target variable:",
                      choices = btn.scale.y.choices, selected = "rating"),
          conditionalPanel(condition = "input.btn.scale.y.variable == 'rating' ",
            checkboxInput(inputId = "btn.scale.y.range", label = "Scale Ratings 0 - 100%",
                          value = FALSE)
          )
        )
      ),
      hr(),
      # TODO: about.md should be exbaned and put in an "about" tab
      # This would probably be the place to put… other information.
      includeMarkdown("about.md")
    )
  )
)
